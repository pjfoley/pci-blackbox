CREATE OR REPLACE FUNCTION Store_Card_Key(_CardKey text, _CardKeyHash text, _CardBIN char(6), _CardLast4 char(4)) RETURNS BIGINT AS $BODY$
DECLARE
_CardID bigint;
BEGIN
INSERT INTO Cards (CardKey, CardKeyHash, CardBIN, CardLast4) VALUES (_CardKey, _CardKeyHash, _CardBIN, _CardLast4) RETURNING CardID INTO STRICT _CardID;
RETURN _CardID;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
