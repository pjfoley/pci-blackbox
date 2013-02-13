CREATE OR REPLACE FUNCTION Encrypt_Card(
OUT CardKey text,
_CardNumber bigint,
_CardExpiryMonth integer,
_CardExpiryYear integer,
_CardHolderName text,
_CardIssueNumber integer,
_CardStartMonth integer,
_CardStartYear integer
) RETURNS TEXT AS $BODY$
DECLARE
_CardHash bytea;
_CardJSON text;
_CardData bytea;
_OK boolean;
BEGIN
CardKey := encode(gen_random_bytes(256),'hex');
_CardHash := digest(CardKey,'sha512');
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
INSERT INTO Cards (CardHash,CardData) VALUES (_CardHash, _CardData) RETURNING TRUE INTO STRICT _OK;
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
