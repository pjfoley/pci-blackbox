CREATE TABLE Authorise3DRequests (
AuthoriseRequestID uuid not null,
AuthCode integer,
RefusalReason text,
PSPReference text,
ResultCode text,
Datestamp timestamptz not null default now(),
PRIMARY KEY (AuthoriseRequestID),
FOREIGN KEY (AuthoriseRequestID) REFERENCES AuthoriseRequests(AuthoriseRequestID)
);
