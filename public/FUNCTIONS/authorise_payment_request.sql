CREATE OR REPLACE FUNCTION Authorise_Payment_Request(
OUT AuthCode integer,
OUT DCCAmount numeric,
OUT DCCSignature text,
OUT FraudResult text,
OUT IssuerURL text,
OUT MD text,
OUT PARequest text,
OUT PSPReference text,
OUT RefusalReason text,
OUT ResultCode text,
_CardKey text,
_PSP text,
_MerchantAccount text,
_URL text,
_Username text,
_Password text,
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
_CardNumber bigint;
_CardExpiryMonth integer;
_CardExpiryYear integer;
_CardHolderName text;
_CardIssueNumber integer;
_CardStartMonth integer;
_CardStartYear integer;
_XMLRequest xml;
_XMLResponse xml;
BEGIN

SELECT * INTO STRICT
    _CardNumber,
    _CardExpiryMonth,
    _CardExpiryYear,
    _CardHolderName,
    _CardIssueNumber,
    _CardStartMonth,
    _CardStartYear
FROM Decrypt_Card(_CardKey);

IF _PSP = 'Adyen' THEN
    _XMLRequest := Format_Adyen_Authorise_Request(
        _MerchantAccount,
        _CurrencyCode,
        _PaymentAmount,
        _Reference,
        _ShopperIP,
        _CardCVC,
        _ShopperEmail,
        _ShopperReference,
        _CardNumber,
        _CardExpiryMonth,
        _CardExpiryYear,
        _CardHolderName
    );
ELSE
    RAISE EXCEPTION 'ERROR_UNSUPPORTED_PSP %', _PSP;
END IF;

_XMLResponse := HTTP_POST_XML(_URL, _Username, _Password, _XMLRequest);

IF _PSP = 'Adyen' THEN
    SELECT
        Parse_Adyen_Authorise_Response.AuthCode,
        Parse_Adyen_Authorise_Response.DCCAmount,
        Parse_Adyen_Authorise_Response.DCCSignature,
        Parse_Adyen_Authorise_Response.FraudResult,
        Parse_Adyen_Authorise_Response.IssuerURL,
        Parse_Adyen_Authorise_Response.MD,
        Parse_Adyen_Authorise_Response.PARequest,
        Parse_Adyen_Authorise_Response.PSPReference,
        Parse_Adyen_Authorise_Response.RefusalReason,
        Parse_Adyen_Authorise_Response.ResultCode
    INTO STRICT
        Authorise_Payment_Request.AuthCode,
        Authorise_Payment_Request.DCCAmount,
        Authorise_Payment_Request.DCCSignature,
        Authorise_Payment_Request.FraudResult,
        Authorise_Payment_Request.IssuerURL,
        Authorise_Payment_Request.MD,
        Authorise_Payment_Request.PARequest,
        Authorise_Payment_Request.PSPReference,
        Authorise_Payment_Request.RefusalReason,
        Authorise_Payment_Request.ResultCode
    FROM Parse_Adyen_Authorise_Response(_XMLResponse);
ELSE
    RAISE EXCEPTION 'ERROR_UNSUPPORTED_PSP %', _PSP;
END IF;

RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
