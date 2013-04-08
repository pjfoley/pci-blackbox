-- This script must be invoked as a superuser
CREATE GROUP nonpci WITH NOSUPERUSER NOCREATEDB;
CREATE GROUP pci    WITH NOSUPERUSER NOCREATEDB;

CREATE DATABASE nonpci WITH OWNER = nonpci;
CREATE DATABASE pci    WITH OWNER = pci;

GRANT CONNECT ON DATABASE pci    TO GROUP pci;
GRANT CONNECT ON DATABASE nonpci TO GROUP nonpci;

CREATE USER "www-data" WITH NOSUPERUSER NOCREATEDB;

ALTER GROUP nonpci ADD USER "www-data";
ALTER GROUP pci    ADD USER "www-data";

-- non-PCI database:

\c nonpci

BEGIN;

CREATE LANGUAGE plperlu;
CREATE EXTENSION pgcrypto;
CREATE EXTENSION "uuid-ossp";

-- plperlu functions, can only be created by superusers
\i nonpci/FUNCTIONS/authorise_payment_request_json_rpc.sql

SET ROLE TO nonpci;

\i nonpci/SEQUENCES/seqmerchantaccounts.sql
\i nonpci/SEQUENCES/seqcards.sql
\i nonpci/TABLES/merchantaccounts.sql
\i nonpci/TABLES/cards.sql
\i nonpci/TABLES/authoriserequests.sql
\i nonpci/FUNCTIONS/get_merchant_account.sql
\i nonpci/FUNCTIONS/store_card_key.sql
\i nonpci/FUNCTIONS/authorise.sql

-- This file needs to be created manually:
\i nonpci/populate.sql
-- Should contain the merchant account credentials obtained from the PSP.
-- Example:
-- INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password) VALUES ('Adyen', 'YourCompanyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompanyInc', 's3cr3tp4ssw0rd');

ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM PUBLIC;

RESET ROLE;

COMMIT;

-- PCI-database:

\c pci

BEGIN;

CREATE LANGUAGE plperlu;
CREATE EXTENSION pgcrypto;
CREATE EXTENSION "uuid-ossp";

-- plperlu functions, can only be created by superusers
\i pci/FUNCTIONS/card_to_json.sql
\i pci/FUNCTIONS/card_from_json.sql
\i pci/FUNCTIONS/http_post_xml.sql

SET ROLE TO pci;

\i pci/TABLES/hashsalts.sql
\i pci/TABLES/cardnumberreferences.sql
\i pci/TABLES/encryptedcards.sql
\i pci/TABLES/encryptedcvcs.sql
\i pci/FUNCTIONS/encrypt_card.sql
\i pci/FUNCTIONS/encrypt_cvc.sql
\i pci/FUNCTIONS/authorise_payment_request.sql
\i pci/FUNCTIONS/authorise_payment_request_3d.sql
\i pci/FUNCTIONS/decrypt_card.sql
\i pci/FUNCTIONS/decrypt_cvc.sql
\i pci/FUNCTIONS/format_adyen_authorise_request.sql
\i pci/FUNCTIONS/format_adyen_authorise_request_3d.sql
\i pci/FUNCTIONS/parse_adyen_authorise_response.sql
\i pci/FUNCTIONS/parse_adyen_authorise_response_3d.sql

ALTER DEFAULT PRIVILEGES REVOKE ALL ON FUNCTIONS FROM PUBLIC;

RESET ROLE;

COMMIT;