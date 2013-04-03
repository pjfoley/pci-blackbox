CREATE TABLE EncryptedCVCs (
CVCKeyHash bytea not null,
CVCData bytea not null,
Datestamp timestamptz not null default now(),
PRIMARY KEY (CVCKeyHash)
);
