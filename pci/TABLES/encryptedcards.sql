CREATE TABLE EncryptedCards (
CardKeyHash bytea not null,
CardNumberReference uuid not null,
CardData bytea not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (CardKeyHash),
FOREIGN KEY (CardNumberReference) REFERENCES CardNumberReferences(CardNumberReference)
);
