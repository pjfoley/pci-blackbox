CREATE OR REPLACE FUNCTION Authorise_Payment_Request(
OUT PSPReference text,
OUT ResultCode text,
OUT AuthCode text,
OUT RefusalReason text,
OUT PARequest text,
OUT IssuerMD text,
OUT IssuerUrl text,
OUT ResultCode text,
_CardKey text,
_PSP text,
_MerchantAccount text,
_CurrencyCode char(3),
_PaymentAmount numeric,
_Reference text,
_ShopperIP inet,
_CardCVC integer,
_ShopperEmail text,
_ShopperReference text,
_FraudOffset integer,
_SelectedBrand text,
_BrowserInfoAcceptHeader text,
_BrowserInfoUserAgent text
) RETURNS RECORD AS $BODY$
DECLARE
BEGIN
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
