CREATE TABLE HashSalts (
HashSaltID integer not null,
HashSalt text not null default gen_salt('bf',8),
Datestamp timestamptz not null default now(),
PRIMARY KEY (HashSaltID),
-- Check to ensure we only have one row in this table:
CHECK(HashSaltID = 1)
);
