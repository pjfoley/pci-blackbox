CREATE OR REPLACE FUNCTION Decrypt_Card(
OUT CardNumber bigint,
OUT CardExpiryMonth integer,
OUT CardExpiryYear integer,
OUT CardHolderName text,
OUT CardIssueNumber integer,
OUT CardStartMonth integer,
OUT CardStartYear integer,
_CardKey text
) RETURNS RECORD AS $BODY$
DECLARE
_CardHash bytea;
_CardJSON text;
_CardData bytea;
_OK boolean;
BEGIN
_CardHash := digest(_CardKey,'sha512');
SELECT CardData INTO STRICT _CardData FROM EncryptedCards WHERE CardHash = _CardHash;
_CardJSON := pgp_sym_decrypt(_CardData,_CardKey);

SELECT * INTO STRICT
    CardNumber,
    CardExpiryMonth,
    CardExpiryYear,
    CardHolderName,
    CardIssueNumber,
    CardStartMonth,
    CardStartYear
FROM Card_From_JSON(_CardJSON);

RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
