CREATE OR REPLACE FUNCTION Encrypt_Card(
OUT CardNumberReference uuid,
OUT CardKey text,
OUT CardBIN char(6),
OUT CardLast4 char(4),
OUT CVCKey text,
_CardNumber text,
_CardExpiryMonth integer,
_CardExpiryYear integer,
_CardHolderName text,
_CardIssueNumber integer,
_CardStartMonth integer,
_CardStartYear integer,
_CardCVC text
) RETURNS RECORD AS $BODY$
DECLARE
_CardNumberHash text;
_CardJSON text;
_CardData bytea;
_OK boolean;
_CardKeyHash bytea;
_HashSalt text;
_HashSaltID integer := 1;
BEGIN

IF _CardNumber IS NULL OR _CardNumber !~ '^[0-9]{13,16}$' OR _CardExpiryMonth IS NULL OR _CardExpiryYear IS NULL OR _CardHolderName IS NULL THEN
    RAISE EXCEPTION 'ERROR_INVALID_INPUT CardNumber % CardExpiryMonth % CardExpiryYear % CardHolderName %', _CardNumber, _CardExpiryMonth, _CardExpiryYear, _CardHolderName;
END IF;

CardBIN := substr(_CardNumber,1,6);
CardLast4 := substr(_CardNumber,length(_CardNumber)-3,4);

SELECT HashSalt INTO _HashSalt FROM HashSalts WHERE HashSaltID = _HashSaltID;
IF NOT FOUND THEN
    INSERT INTO HashSalts (HashSaltID) VALUES (_HashSaltID) RETURNING HashSalt INTO STRICT _HashSalt;
END IF;

_CardNumberHash := crypt(_CardNumber, _HashSalt);
SELECT CardNumberReferences.CardNumberReference INTO Encrypt_Card.CardNumberReference FROM CardNumberReferences WHERE CardNumberReferences.CardNumberHash = _CardNumberHash;
IF NOT FOUND THEN
    INSERT INTO CardNumberReferences (CardNumberHash) VALUES (_CardNumberHash) RETURNING CardNumberReferences.CardNumberReference INTO STRICT Encrypt_Card.CardNumberReference;
END IF;

CardKey := encode(gen_random_bytes(256),'hex');
_CardKeyHash := digest(CardKey,'sha512');
_CardJSON := Card_To_JSON(
    _CardNumber,
    _CardExpiryMonth,
    _CardExpiryYear,
    _CardHolderName,
    _CardIssueNumber,
    _CardStartMonth,
    _CardStartYear
);
_CardData := pgp_sym_encrypt(_CardJSON,CardKey,'cipher-algo=aes256');

INSERT INTO EncryptedCards (CardKeyHash,CardNumberReference,CardData) VALUES (_CardKeyHash, CardNumberReference, _CardData) RETURNING TRUE INTO STRICT _OK;

IF _CardCVC IS NOT NULL THEN
    SELECT Encrypt_CVC.CVCKey INTO STRICT Encrypt_Card.CVCKey FROM Encrypt_CVC(_CardCVC);
END IF;

RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Encrypt_Card(_CardNumber text, _CardExpiryMonth integer, _CardExpiryYear integer, _CardHolderName text, _CardIssueNumber integer, _CardStartMonth integer, _CardStartYear integer, _CardCVC text) FROM PUBLIC;
GRANT  ALL ON FUNCTION Encrypt_Card(_CardNumber text, _CardExpiryMonth integer, _CardExpiryYear integer, _CardHolderName text, _CardIssueNumber integer, _CardStartMonth integer, _CardStartYear integer, _CardCVC text) TO GROUP pci;
