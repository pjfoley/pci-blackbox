CREATE OR REPLACE FUNCTION Authorise_3D(
OUT TermURL text,
_AuthoriseRequestID uuid,
_MD text,
_PaRes text,
_Remote_Addr inet,
_HTTP_User_Agent text,
_HTTP_Accept text
) RETURNS TEXT AS $BODY$
DECLARE
_PCIBlackBoxURL text;
_PSP text;
_MerchantAccount text;
_URL text;
_Username text;
_Password text;
_PSPReference text;
_ResultCode text;
_AuthCode integer;
_Datestamp timestamptz;
BEGIN

SELECT MerchantAccounts.PSP, MerchantAccounts.MerchantAccount, MerchantAccounts.URL, MerchantAccounts.Username, MerchantAccounts.Password, MerchantAccounts.PCIBlackBoxURL
INTO STRICT _PSP, _MerchantAccount, _URL, _Username, _Password, _PCIBlackBoxURL
FROM AuthoriseRequests
INNER JOIN MerchantAccounts ON (MerchantAccounts.MerchantAccountID = AuthoriseRequests.MerchantAccountID)
WHERE AuthoriseRequests.AuthoriseRequestID = _AuthoriseRequestID;

SELECT
    Authorise_Payment_Request_3D_JSON_RPC.PSPReference,
    Authorise_Payment_Request_3D_JSON_RPC.ResultCode,
    Authorise_Payment_Request_3D_JSON_RPC.AuthCode
INTO STRICT
    _PSPReference,
    _ResultCode,
    _AuthCode
FROM Authorise_Payment_Request_3D_JSON_RPC(
    _PCIBlackBoxURL,
    _PSP,
    _MerchantAccount,
    _URL,
    _Username,
    _Password,
    _HTTP_Accept,
    _HTTP_User_Agent,
    _MD,
    _PaRes,
    _Remote_Addr
);

INSERT INTO Authorise3DRequests (AuthoriseRequestID, PSPReference, ResultCode, AuthCode)
VALUES (_AuthoriseRequestID, _PSPReference, _ResultCode, _AuthCode)
RETURNING Datestamp INTO STRICT _Datestamp;

-- In the real back-end, set this to whatever url the customer
-- should be directed after the payment has been made,
-- maybe different url depending on whether it was
-- a successful payment or not.
TermURL := 'http://bit.ly/17t13ft';

RETURN;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Authorise_3D(_AuthoriseRequestID uuid, _MD text, _PaRes text, _Remote_Addr inet, _HTTP_User_Agent text, _HTTP_Accept text) FROM PUBLIC;
GRANT  ALL ON FUNCTION Authorise_3D(_AuthoriseRequestID uuid, _MD text, _PaRes text, _Remote_Addr inet, _HTTP_User_Agent text, _HTTP_Accept text) TO GROUP nonpci;
