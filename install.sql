DROP DATABASE nonpci;
DROP DATABASE pci;

CREATE DATABASE nonpci;
CREATE DATABASE pci;

\c nonpci
\i nonpci/SEQUENCES/seqmerchantaccounts.sql
\i nonpci/SEQUENCES/seqcards.sql
\i nonpci/TABLES/merchantaccounts.sql
\i nonpci/TABLES/cards.sql
\i nonpci/FUNCTIONS/get_merchant_account.sql
\i nonpci/FUNCTIONS/store_card_key.sql
\i nonpci/populate.sql

\c pci
CREATE LANGUAGE plperlu;
CREATE EXTENSION pgcrypto;
\i pci/TABLES/encryptedcards.sql
\i pci/FUNCTIONS/encrypt_card.sql
\i pci/FUNCTIONS/card_to_json.sql
\i pci/FUNCTIONS/authorise_payment_request.sql
\i pci/FUNCTIONS/decrypt_card.sql
\i pci/FUNCTIONS/card_from_json.sql
\i pci/FUNCTIONS/format_adyen_authorise_request.sql
\i pci/FUNCTIONS/http_post_xml.sql
\i pci/FUNCTIONS/parse_adyen_authorise_response.sql



