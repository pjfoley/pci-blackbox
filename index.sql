\c nonpci
\i public/SEQUENCES/seqmerchantaccounts.sql
\i public/TABLES/merchantaccounts.sql
\i public/FUNCTIONS/get_merchant_account.sql

INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password) VALUES ('Adyen', 'TrustlyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.TrustlyGroupAB', 'xxxxxxxxxxxxxx');

\c pci
CREATE LANGUAGE plperlu;
\i public/TABLES/cards.sql
\i public/FUNCTIONS/encrypt_card.sql
\i public/FUNCTIONS/card_to_json.sql
\i public/FUNCTIONS/authorise_payment_request.sql
\i public/FUNCTIONS/decrypt_card.sql
\i public/FUNCTIONS/card_from_json.sql
\i public/FUNCTIONS/format_adyen_authorise_request.sql
\i public/FUNCTIONS/http_post_xml.sql
\i public/FUNCTIONS/parse_adyen_authorise_response.sql



