CREATE TABLE CardNumberReferences (
CardNumberReference uuid not null default uuid_generate_v4(),
CardNumberHash text not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (CardNumberReference),
UNIQUE(CardNumberHash)
);
