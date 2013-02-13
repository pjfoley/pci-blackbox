CREATE DATABASE nonpci;
CREATE DATABASE pci;

\c nonpci
\i nonpci/SEQUENCES/seqmerchantaccounts.sql
\i nonpci/TABLES/merchantaccounts.sql
\i nonpci/FUNCTIONS/get_merchant_account.sql

-- You also need to populate MerchantAccounts. Contact one of the supported PSPs to get a test account:
-- INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password) VALUES ('Adyen', 'YourCompanyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompanyInc', 'xxxxxxxxx');

\c pci
CREATE LANGUAGE plperlu;
CREATE EXTENSION pgcrypto;
\i pci/TABLES/cards.sql
\i pci/FUNCTIONS/encrypt_card.sql
\i pci/FUNCTIONS/card_to_json.sql
\i pci/FUNCTIONS/authorise_payment_request.sql
\i pci/FUNCTIONS/decrypt_card.sql
\i pci/FUNCTIONS/card_from_json.sql
\i pci/FUNCTIONS/format_adyen_authorise_request.sql
\i pci/FUNCTIONS/http_post_xml.sql
\i pci/FUNCTIONS/parse_adyen_authorise_response.sql



