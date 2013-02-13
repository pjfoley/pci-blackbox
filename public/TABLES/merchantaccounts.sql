CREATE TABLE MerchantAccounts (
MerchantAccountID integer not null default nextval('seqMerchantAccounts'),
PSP text not null,
MerchantAccount text not null,
URL text not null,
Username text not null,
Password text not null,
PRIMARY KEY (MerchantAccountID),
UNIQUE(PSP,MerchantAccount)
);

-- INSERT INTO MerchantAccounts VALUES (PSP, MerchantAccount, URL, Username, Password)
-- VALUES ('Adyen', 'TrustlyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.TrustlyGroupAB', 'xxxxxxxxxxxxxx');

