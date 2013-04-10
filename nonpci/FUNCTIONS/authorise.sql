CREATE OR REPLACE FUNCTION Authorise(
OUT AuthoriseRequestID uuid,
OUT TermURL text,
OUT IssuerURL text,
OUT MD text,
OUT PARequest text,
_OrderID text,
_CurrencyCode char(3),
_PaymentAmount numeric,
_CardNumberReference uuid,
_CardKey text,
_CardBIN char(6),
_CardLast4 char(4),
_CVCKey text,
_Remote_Addr inet,
_HTTP_User_Agent text,
_HTTP_Accept text
) RETURNS RECORD AS $BODY$
DECLARE
_ record;
_PCIBlackBoxURL text;
_PSP text;
_MerchantAccount text;
_URL text;
_Username text;
_Password text;
_FraudOffset integer;
_SelectedBrand text;
_CardID bigint;
_Reference text;
_ShopperEmail text;
_ShopperReference text;
_MerchantAccountID integer;

_AuthCode integer;
_DCCAmount numeric;
_DCCSignature text;
_FraudResult text;
_PSPReference text;
_RefusalReason text;
_ResultCode text;
BEGIN

-- In production, resolve these variables from OrderID:
SELECT
    'reference'||random()::text,
    'joe@joe.com',
    'shopperref'||random()::text
INTO STRICT
    _Reference,
    _ShopperEmail,
    _ShopperReference;

_CardID := Store_Card_Key(_CardNumberReference, _CardKey, _CardBIN, _CardLast4);

-- There is only one merchant account so far
SELECT MerchantAccountID, PSP, MerchantAccount, URL, Username, Password, PCIBlackBoxURL INTO STRICT _MerchantAccountID, _PSP, _MerchantAccount, _URL, _Username, _Password, _PCIBlackBoxURL FROM MerchantAccounts;

_FraudOffset := NULL;
_SelectedBrand := NULL;

SELECT
    Authorise_Payment_Request_JSON_RPC.AuthCode,
    Authorise_Payment_Request_JSON_RPC.DCCAmount,
    Authorise_Payment_Request_JSON_RPC.DCCSignature,
    Authorise_Payment_Request_JSON_RPC.FraudResult,
    Authorise_Payment_Request_JSON_RPC.IssuerURL,
    Authorise_Payment_Request_JSON_RPC.MD,
    Authorise_Payment_Request_JSON_RPC.PARequest,
    Authorise_Payment_Request_JSON_RPC.PSPReference,
    Authorise_Payment_Request_JSON_RPC.RefusalReason,
    Authorise_Payment_Request_JSON_RPC.ResultCode
INTO STRICT
    _AuthCode,
    _DCCAmount,
    _DCCSignature,
    _FraudResult,
    Authorise.IssuerURL,
    Authorise.MD,
    Authorise.PARequest,
    _PSPReference,
    _RefusalReason,
    _ResultCode
FROM Authorise_Payment_Request_JSON_RPC(
    _PCIBlackBoxURL,
    _CardKey,
    _CVCKey,
    _PSP,
    _MerchantAccount,
    _URL,
    _Username,
    _Password,
    _CurrencyCode,
    _PaymentAmount,
    _Reference,
    _Remote_Addr,
    _ShopperEmail,
    _ShopperReference,
    _FraudOffset,
    _SelectedBrand,
    _HTTP_Accept,
    _HTTP_User_Agent
);

INSERT INTO AuthoriseRequests (OrderID, CurrencyCode, PaymentAmount, MerchantAccountID, CardID, AuthCode, DCCAmount, DCCSignature, FraudResult, IssuerURL, MD, PARequest, PSPReference, RefusalReason, ResultCode)
VALUES (_OrderID, _CurrencyCode, _PaymentAmount, _MerchantAccountID, _CardID, _AuthCode, _DCCAmount, _DCCSignature, _FraudResult, Authorise.IssuerURL, Authorise.MD, Authorise.PARequest, _PSPReference, _RefusalReason, _ResultCode)
RETURNING AuthoriseRequests.AuthoriseRequestID INTO STRICT Authorise.AuthoriseRequestID;

-- Set this to your own domain-name:

TermURL := _PCIBlackBoxURL || '/submit_paresponse?authoriserequestid=' || AuthoriseRequestID;

RETURN;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Authorise(_OrderID text, _CurrencyCode char(3), _PaymentAmount numeric, _CardNumberReference uuid, _CardKey text, _CardBIN char(6), _CardLast4 char(4), _CVCKey text, _Remote_Addr inet, _HTTP_User_Agent text, _HTTP_Accept text) FROM PUBLIC;
GRANT  ALL ON FUNCTION Authorise(_OrderID text, _CurrencyCode char(3), _PaymentAmount numeric, _CardNumberReference uuid, _CardKey text, _CardBIN char(6), _CardLast4 char(4), _CVCKey text, _Remote_Addr inet, _HTTP_User_Agent text, _HTTP_Accept text) TO GROUP nonpci;
