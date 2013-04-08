CREATE OR REPLACE FUNCTION Get_Hash_Salt(OUT HashSalt text) RETURNS TEXT AS $BODY$
DECLARE
BEGIN
SELECT
    MerchantAccounts.HashSalt
INTO STRICT
    Get_Hash_Salt.HashSalt
FROM MerchantAccounts;
IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR_MERCHANT_ACCOUNT_NOT_FOUND No merchant account found, you need to populate the table MerchantAccounts';
END IF;
END;
$BODY$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Get_Hash_Salt() FROM PUBLIC;
GRANT  ALL ON FUNCTION Get_Hash_Salt() TO "nonpci";
