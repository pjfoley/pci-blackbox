CREATE TABLE EncryptedCards (
CardHash bytea not null,
CardData bytea not null,
PRIMARY KEY (CardHash)
);
