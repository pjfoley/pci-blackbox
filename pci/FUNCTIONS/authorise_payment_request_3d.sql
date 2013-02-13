CREATE OR REPLACE FUNCTION Authorise_Payment_Request_3D(
OUT PSPReference text,
OUT ResultCode text,
OUT AuthCode text,
OUT RefusalReason text,
_BrowserInfoAcceptHeader text,
_BrowserInfoUserAgent text,
_IssuerMD text,
_IssuerPAResponse text,
_ShopperIP inet
) RETURNS RECORD AS $BODY$
DECLARE
BEGIN
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
