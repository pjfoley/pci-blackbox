CREATE OR REPLACE FUNCTION HTTP_POST_JSON(
_URL text,
_Method text,
_Params text
) RETURNS text AS $BODY$
use strict;
use warnings;
use JSON;
use WWW::Curl::Easy;
use Data::Dumper;

my ($url,$method,$params) = @_;

use JSON::RPC::Simple::Client;
my $c = JSON::RPC::Simple::Client->new($url);
my $r = $c->$method(JSON::from_json($params));
unless (ref($r))
{
    return $r;
}

return JSON::to_json($r,{pretty => 1, canonical => 1});
$BODY$ LANGUAGE plperlu;
