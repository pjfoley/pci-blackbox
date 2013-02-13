CREATE OR REPLACE FUNCTION HTTP_POST_XML(
_URL text,
_Username text,
_Password text,
_XML xml
) RETURNS xml AS $BODY$
use strict;
use warnings;
use WWW::Curl::Easy;

my ($url,$username,$password,$xml) = @_;

my $ch = new WWW::Curl::Easy;
$ch->setopt(CURLOPT_HEADER,0);
$ch->setopt(CURLOPT_URL, $url);
$ch->setopt(CURLOPT_USERNAME,$username);
$ch->setopt(CURLOPT_PASSWORD,$password);
$ch->setopt(CURLOPT_POST,1);
$ch->setopt(CURLOPT_NOPROGRESS,0);
$ch->setopt(CURLOPT_POSTFIELDS,$xml);
$ch->setopt(CURLOPT_SSL_VERIFYPEER,1);
$ch->setopt(CURLOPT_SSL_VERIFYHOST,2);

my $response_body;

open (my $fileb, ">", \$response_body);
$ch->setopt(CURLOPT_WRITEDATA,$fileb);

my $retcode = $ch->perform;

if ($retcode == 0) {
    my $response_code = $ch->getinfo(CURLINFO_HTTP_CODE);
} else {
    my $curlerrortext = $ch->strerror($retcode);
    die "ERROR_HTTP_POST_XML CURL_ERROR retcode: $retcode curlerrortext: $curlerrortext";
}

return $response_body;
$BODY$ LANGUAGE plperlu;

