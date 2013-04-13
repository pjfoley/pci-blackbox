CREATE TABLE AuthoriseRequests (
AuthoriseRequestID uuid not null default uuid_generate_v4(),
OrderID text,
CurrencyCode char(3),
PaymentAmount numeric,
MerchantAccountID integer not null,
CardID bigint not null,
AuthCode integer,
IssuerURL text,
MD text,
PaReq text,
PSPReference text,
ResultCode text not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (AuthoriseRequestID),
FOREIGN KEY (MerchantAccountID) REFERENCES MerchantAccounts(MerchantAccountID),
FOREIGN KEY (CardID) REFERENCES Cards(CardID)
);
