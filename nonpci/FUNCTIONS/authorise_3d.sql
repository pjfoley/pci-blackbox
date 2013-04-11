CREATE OR REPLACE FUNCTION Authorise_3D(
OUT ResultCode text,
OUT TermURL text,
_AuthoriseRequestID uuid,
_MD text,
_PaRes text,
_Remote_Addr inet,
_HTTP_User_Agent text,
_HTTP_Accept text
) RETURNS RECORD AS $BODY$
DECLARE
_PCIBlackBoxURL text;
_PSP text;
_MerchantAccount text;
_URL text;
_Username text;
_Password text;
_PSPReference text;
_AuthCode integer;
_RefusalReason text;
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
    Authorise_Payment_Request_3D_JSON_RPC.AuthCode,
    Authorise_Payment_Request_3D_JSON_RPC.RefusalReason
INTO STRICT
    _PSPReference,
    Authorise_3D.ResultCode,
    _AuthCode,
    _RefusalReason
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

INSERT INTO Authorise3DRequests (AuthoriseRequestID, PSPReference, ResultCode, AuthCode, RefusalReason)
VALUES (_AuthoriseRequestID, _PSPReference, Authorise_3D.ResultCode, _AuthCode, _RefusalReason)
RETURNING Datestamp INTO STRICT _Datestamp;

-- TEST
TermURL := 'http://bit.ly/17t13ft';

RETURN;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Authorise_3D(_AuthoriseRequestID uuid, _MD text, _PaRes text, _Remote_Addr inet, _HTTP_User_Agent text, _HTTP_Accept text) FROM PUBLIC;
GRANT  ALL ON FUNCTION Authorise_3D(_AuthoriseRequestID uuid, _MD text, _PaRes text, _Remote_Addr inet, _HTTP_User_Agent text, _HTTP_Accept text) TO GROUP nonpci;
