CREATE OR REPLACE FUNCTION Get_Merchant_Account(
OUT URL text,
OUT Username text,
OUT Password text,
_PSP text,
_MerchantAccount text
) RETURNS RECORD AS $BODY$
DECLARE
BEGIN
SELECT
    MerchantAccounts.URL,
    MerchantAccounts.Username,
    MerchantAccounts.Password
INTO
    Get_Merchant_Account.URL,
    Get_Merchant_Account.Username,
    Get_Merchant_Account.Password
FROM MerchantAccounts
WHERE MerchantAccounts.PSP = _PSP AND MerchantAccounts.MerchantAccount = _MerchantAccount;
IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR_MERCHANT_ACCOUNT_NOT_FOUND PSP % MerchantAccount % not found, you need to populate the table MerchantAccounts', _PSP, _MerchantAccount;
END IF;
END;
$BODY$ LANGUAGE plpgsql;
