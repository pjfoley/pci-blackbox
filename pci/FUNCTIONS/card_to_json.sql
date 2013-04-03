CREATE OR REPLACE FUNCTION Card_To_JSON(
OUT CardJSON text,
_CardNumber text,
_CardExpiryMonth integer,
_CardExpiryYear integer,
_CardHolderName text,
_CardIssueNumber integer,
_CardStartMonth integer,
_CardStartYear integer
) RETURNS TEXT AS $BODY$
use strict;
use warnings;

use JSON;

return JSON::to_json({
   cardnumber      => shift,
   cardexpirymonth => shift,
   cardexpiryyear  => shift,
   cardholdername  => shift,
   cardissuenumber => shift,
   cardstartmonth  => shift,
   cardstartyear   => shift
}, {canonical => 1});
$BODY$ LANGUAGE plperlu IMMUTABLE;
