CREATE TABLE AuthoriseRequests (
AuthoriseRequestID uuid not null default uuid_generate_v4(),
OrderID bigint not null,
CurrencyCode char(3),
PaymentAmount numeric,
MerchantAccountID integer not null,
CardID bigint not null,
AuthCode integer,
DCCAmount numeric,
DCCSignature text,
FraudResult text,
IssuerURL text,
MD text,
PARequest text,
PSPReference text,
RefusalReason text,
ResultCode text,
Datestamp timestamptz not null default now(),
PRIMARY KEY (AuthoriseRequestID),
FOREIGN KEY (MerchantAccountID) REFERENCES MerchantAccounts(MerchantAccountID),
FOREIGN KEY (CardID) REFERENCES Cards(CardID)
);
