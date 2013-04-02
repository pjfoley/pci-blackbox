CREATE OR REPLACE FUNCTION Encrypt_Card(
OUT CardHash text,
OUT CardKey text,
_CardNumber bigint,
_CardExpiryMonth integer,
_CardExpiryYear integer,
_CardHolderName text,
_CardIssueNumber integer,
_CardStartMonth integer,
_CardStartYear integer,
_HashSalt text
) RETURNS RECORD AS $BODY$
DECLARE
_CardJSON text;
_CardData bytea;
_OK boolean;
_CardKeyHash bytea;
BEGIN

IF _CardNumber IS NULL OR _CardExpiryMonth IS NULL OR _CardExpiryYear IS NULL OR _CardHolderName IS NULL THEN
    RAISE EXCEPTION 'ERROR_NULL_INPUT CardNumber % CardExpiryMonth % CardExpiryYear % CardHolderName %', _CardNumber, _CardExpiryMonth, _CardExpiryYear, _CardHolderName;
END IF;

CardHash := crypt(_CardNumber::text || _CardExpiryMonth::text || _CardExpiryYear::text, _HashSalt);

PERFORM 1 FROM EncryptedCards WHERE EncryptedCards.CardHash = Encrypt_Card.CardHash;
IF FOUND THEN
    -- Card already registered, only return CardHash, CardKey will be NULL in output
    RETURN;
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

INSERT INTO EncryptedCards (CardKeyHash,CardHash,CardData) VALUES (_CardKeyHash, CardHash, _CardData) RETURNING TRUE INTO STRICT _OK;
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
