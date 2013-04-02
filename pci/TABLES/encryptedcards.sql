CREATE TABLE EncryptedCards (
CardKeyHash bytea not null,
CardHash text not null,
CardData bytea not null,
PRIMARY KEY (CardKeyHash)
);
