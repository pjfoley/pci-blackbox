CREATE TABLE Cards (
CardID bigint not null default nextval('seqCards'),
CardKey text not null,
PRIMARY KEY (CardID),
CHECK(CardKey ~ '^[0-9a-f]+$'),
UNIQUE(CardKey)
);
