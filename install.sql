-- This script must be invoked as a superuser
CREATE USER nonpci WITH NOSUPERUSER NOCREATEDB;
CREATE USER pci WITH NOSUPERUSER NOCREATEDB;

CREATE DATABASE nonpci WITH OWNER = nonpci;
CREATE DATABASE pci WITH OWNER = pci;

BEGIN;

\c nonpci

CREATE EXTENSION pgcrypto;

SET ROLE TO nonpci;

\i nonpci/SEQUENCES/seqmerchantaccounts.sql
\i nonpci/SEQUENCES/seqcards.sql
\i nonpci/TABLES/merchantaccounts.sql
\i nonpci/TABLES/cards.sql
\i nonpci/FUNCTIONS/get_merchant_account.sql
\i nonpci/FUNCTIONS/store_card_key.sql

-- This file needs to be created manually:
\i nonpci/populate.sql
-- Should contain the merchant account credentials obtained from the PSP.
-- Example:
-- INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password) VALUES ('Adyen', 'YourCompanyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompanyInc', 's3cr3tp4ssw0rd');

ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM PUBLIC;

RESET ROLE;

\c pci

CREATE LANGUAGE plperlu;
CREATE EXTENSION pgcrypto;
CREATE EXTENSION "uuid-ossp";

SET ROLE TO pci;

\i pci/TABLES/cardnumberreferences.sql
\i pci/TABLES/encryptedcards.sql
\i pci/TABLES/encryptedcvcs.sql
\i pci/FUNCTIONS/encrypt_card.sql
\i pci/FUNCTIONS/encrypt_cvc.sql
\i pci/FUNCTIONS/encrypt_card_cvc.sql
\i pci/FUNCTIONS/card_to_json.sql
\i pci/FUNCTIONS/authorise_payment_request.sql
\i pci/FUNCTIONS/authorise_payment_request_3d.sql
\i pci/FUNCTIONS/decrypt_card.sql
\i pci/FUNCTIONS/decrypt_cvc.sql
\i pci/FUNCTIONS/card_from_json.sql
\i pci/FUNCTIONS/format_adyen_authorise_request.sql
\i pci/FUNCTIONS/format_adyen_authorise_request_3d.sql
\i pci/FUNCTIONS/http_post_xml.sql
\i pci/FUNCTIONS/parse_adyen_authorise_response.sql
\i pci/FUNCTIONS/parse_adyen_authorise_response_3d.sql

ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM PUBLIC;

RESET ROLE;

GRANT CONNECT ON DATABASE pci TO "www-data";

COMMIT;