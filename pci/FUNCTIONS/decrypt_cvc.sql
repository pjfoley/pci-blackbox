CREATE OR REPLACE FUNCTION Decrypt_CVC(
OUT CardCVC text,
_CVCKey text
) RETURNS TEXT AS $BODY$
DECLARE
_CVCKeyHash bytea;
_CVCData bytea;
_OK boolean;
BEGIN
_CVCKeyHash := digest(_CVCKey,'sha512');
DELETE FROM EncryptedCVCs WHERE CVCKeyHash = _CVCKeyHash RETURNING CVCData INTO STRICT _CVCData;
CardCVC := pgp_sym_decrypt(_CVCData,_CVCKey);
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
