CREATE TABLE PaResponses (
AuthoriseRequestID uuid not null,
PaRes text not null,
MD text,
Datestamp timestamptz not null default now(),
PRIMARY KEY (AuthoriseRequestID)
);
