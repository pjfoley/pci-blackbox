CREATE TABLE EncryptedCards (
CardKeyHash bytea not null,
CardHash text not null,
CardData bytea not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (CardKeyHash)
);
