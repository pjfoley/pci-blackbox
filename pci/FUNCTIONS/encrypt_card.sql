CREATE OR REPLACE FUNCTION Encrypt_Card(
OUT CardKey text,
OUT CardKeyHash text,
OUT CardBIN char(6),
OUT CardLast4 char(4),
_CardNumber text,
_CardExpiryMonth integer,
_CardExpiryYear integer,
_CardHolderName text,
_CardIssueNumber integer,
_CardStartMonth integer,
_CardStartYear integer,
_HashSalt text
) RETURNS RECORD AS $BODY$
DECLARE
_CardHash text;
_CardJSON text;
_CardData bytea;
_OK boolean;
_CardKeyHash bytea;
BEGIN

IF _CardNumber IS NULL OR _CardNumber !~ '^[0-9]{13,16}$' OR _CardExpiryMonth IS NULL OR _CardExpiryYear IS NULL OR _CardHolderName IS NULL THEN
    RAISE EXCEPTION 'ERROR_INVALID_INPUT CardNumber % CardExpiryMonth % CardExpiryYear % CardHolderName %', _CardNumber, _CardExpiryMonth, _CardExpiryYear, _CardHolderName;
END IF;

CardBIN := substr(_CardNumber,1,6);
CardLast4 := substr(_CardNumber,length(_CardNumber)-3,4);

_CardHash := crypt(_CardNumber || _CardExpiryMonth::text || _CardExpiryYear::text, _HashSalt);
SELECT EncryptedCards.CardKeyHash INTO _CardKeyHash FROM EncryptedCards WHERE EncryptedCards.CardHash = _CardHash;
IF FOUND THEN
    -- Card already registered, only return CardKeyHash, CardKey will be NULL in output
    CardKeyHash := encode(_CardKeyHash,'hex');
    RETURN;
END IF;

CardKey := encode(gen_random_bytes(256),'hex');
_CardKeyHash := digest(CardKey,'sha512');
CardKeyHash := encode(_CardKeyHash,'hex');
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

INSERT INTO EncryptedCards (CardKeyHash,CardHash,CardData) VALUES (_CardKeyHash, _CardHash, _CardData) RETURNING TRUE INTO STRICT _OK;

RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
