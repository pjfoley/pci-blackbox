CREATE OR REPLACE FUNCTION Get_Merchant_Account(
OUT PSP text,
OUT MerchantAccount text,
OUT URL text,
OUT Username text,
OUT Password text
) RETURNS RECORD AS $BODY$
DECLARE
BEGIN
SELECT
    MerchantAccounts.PSP,
    MerchantAccounts.MerchantAccount,
    MerchantAccounts.URL,
    MerchantAccounts.Username,
    MerchantAccounts.Password
INTO STRICT
    Get_Merchant_Account.PSP,
    Get_Merchant_Account.MerchantAccount,
    Get_Merchant_Account.URL,
    Get_Merchant_Account.Username,
    Get_Merchant_Account.Password
FROM MerchantAccounts;
IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR_MERCHANT_ACCOUNT_NOT_FOUND No merchant account found, you need to populate the table MerchantAccounts';
END IF;
END;
$BODY$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Get_Merchant_Account() FROM PUBLIC;
GRANT  ALL ON FUNCTION Get_Merchant_Account() TO GROUP nonpci;
