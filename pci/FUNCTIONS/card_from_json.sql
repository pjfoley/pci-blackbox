CREATE OR REPLACE FUNCTION Card_From_JSON(
OUT CardNumber bigint,
OUT CardExpiryMonth integer,
OUT CardExpiryYear integer,
OUT CardHolderName text,
OUT CardIssueNumber integer,
OUT CardStartMonth integer,
OUT CardStartYear integer,
_CardJSON text
) RETURNS RECORD AS $BODY$
use strict;
use warnings;

use JSON;

return JSON::from_json(shift);
$BODY$ LANGUAGE plperlu;
