CREATE TABLE MerchantAccounts (
MerchantAccountID integer not null default nextval('seqMerchantAccounts'),
PSP text not null,
MerchantAccount text not null,
URL text not null,
Username text not null,
Password text not null,
HashSalt text not null default gen_salt('bf',8),
Datestamp timestamptz not null default now(),
PRIMARY KEY (MerchantAccountID),
UNIQUE(PSP,MerchantAccount)
);

