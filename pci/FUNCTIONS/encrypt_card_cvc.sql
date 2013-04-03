CREATE OR REPLACE FUNCTION Encrypt_Card_CVC(
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
_HashSalt text,
_CardCVC text
) RETURNS RECORD AS $BODY$
DECLARE
BEGIN

SELECT
    Encrypt_Card.CardNumberReference,
    Encrypt_Card.CardKey,
    Encrypt_Card.CardBIN,
    Encrypt_Card.CardLast4
INTO STRICT
    Encrypt_Card_CVC.CardNumberReference,
    Encrypt_Card_CVC.CardKey,
    Encrypt_Card_CVC.CardBIN,
    Encrypt_Card_CVC.CardLast4
FROM Encrypt_Card(
    _CardNumber,
    _CardExpiryMonth,
    _CardExpiryYear,
    _CardHolderName,
    _CardIssueNumber,
    _CardStartMonth,
    _CardStartYear,
    _HashSalt
);

SELECT Encrypt_CVC.CVCKey INTO STRICT Encrypt_Card_CVC.CVCKey FROM Encrypt_CVC(_CardCVC);

RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
