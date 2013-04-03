CREATE TABLE Cards (
CardID bigint not null default nextval('seqCards'),
CardKey text not null,
CardKeyHash text not null,
CardBIN char(6) not null,
CardLast4 char(4) not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (CardID),
CHECK(CardKey ~ '^[0-9a-f]+$'),
CHECK(CardKeyHash ~ '^[0-9a-f]+$'),
CHECK(CardBIN ~ '^[0-9]{6}$'),
CHECK(CardLast4 ~ '^[0-9]{4}$'),
UNIQUE(CardKey)
);
