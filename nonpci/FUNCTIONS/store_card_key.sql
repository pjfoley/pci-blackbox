CREATE OR REPLACE FUNCTION Store_Card_Key(_CardNumberReference uuid, _CardKey text, _CardBIN char(6), _CardLast4 char(4)) RETURNS BIGINT AS $BODY$
DECLARE
_CardID bigint;
BEGIN
INSERT INTO Cards (CardNumberReference, CardKey, CardBIN, CardLast4) VALUES (_CardNumberReference, _CardKey, _CardBIN, _CardLast4) RETURNING CardID INTO STRICT _CardID;
RETURN _CardID;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Store_Card_Key(_CardNumberReference uuid, _CardKey text, _CardBIN char(6), _CardLast4 char(4)) FROM PUBLIC;
GRANT  ALL ON FUNCTION Store_Card_Key(_CardNumberReference uuid, _CardKey text, _CardBIN char(6), _CardLast4 char(4)) TO "www-data";
