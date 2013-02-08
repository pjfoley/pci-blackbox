#!/usr/bin/perl
use strict;
use warnings;
no warnings qw(uninitialized);

use DBI;
use DBIx::Pg::CallFunction;
use Test::More;
use Test::Deep;
use Data::Dumper;
plan tests => 1;

# Connect to PostgreSQL and create DBIx::Pg::CallFunction object

my $dbh = DBI->connect("dbi:Pg:", '', '', {pg_enable_utf8 => 1, PrintError => 0});
my $pg = DBIx::Pg::CallFunction->new($dbh);

$dbh->do(q{
-- Silent debug, notice and warning messages
SET client_min_messages = 'error';
});

my $url      = 'https://pal-test.adyen.com/pal/servlet/soap/Payment';
my $username = 'ws@Company.CompanyName';
my $password = 'xxxxxxxxxxxxxxxxxxxxxxxxx';

my $order = {
    _merchantaccount  => 'TrustlyCOM',
    _currencycode     => 'EUR',
    _paymentamount    => 2000,
    _reference        => 'Your Reference Here',
    _shopperip        => '61.249.12.12',
    _cardcvc          => 737,
    _shopperemail     => 's.hopper@test.com',
    _shopperreference => 'Simon Hopper',
    _cardnumber       => 4111111111111111,
    _cardexpirymonth  => 12,
    _cardexpiryyear   => 2012,
    _cardholdername   => 'Adyen Test'
};


my $request_xml = $pg->format_adyen_authorise_xml($order);

like($request_xml, qr!
    <soap:Envelope\ xmlns:soap="http://schemas\.xmlsoap\.org/soap/envelope/"\ xmlns:xsd="http://www\.w3\.org/2001/XMLSchema"\ xmlns:xsi="http://www\.w3\.org/2001/XMLSchema-instance">\s*
        <soap:Body>\s*
            <ns1:authorise\ xmlns:ns1="http://payment\.services\.adyen\.com">\s*
                <ns1:paymentRequest>\s*
                    <amount\ xmlns="http://payment\.services\.adyen\.com">\s*
                        <currency\ xmlns="http://common\.services\.adyen\.com">$order->{_currencycode}</currency>\s*
                        <value\ xmlns="http://common\.services\.adyen\.com">$order->{_paymentamount}</value>\s*
                    </amount>\s*
                    <card\ xmlns="http://payment\.services\.adyen\.com">\s*
                        <cvc>$order->{_cardcvc}</cvc>\s*
                        <expiryMonth>$order->{_cardexpirymonth}</expiryMonth>\s*
                        <expiryYear>$order->{_cardexpiryyear}</expiryYear>\s*
                        <holderName>\Q$order->{_cardholdername}\E</holderName>\s*
                        <number>$order->{_cardnumber}</number>\s*
                    </card>\s*
                    <merchantAccount\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_merchantaccount}\E</merchantAccount>\s*
                    <reference\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_reference}\E</reference>\s*
                    <shopperEmail\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_shopperemail}\E</shopperEmail>\s*
                    <shopperIP\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_shopperip}\E</shopperIP>\s*
                    <shopperReference\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_shopperreference}\E</shopperReference>\s*
                </ns1:paymentRequest>\s*
            </ns1:authorise>\s*
        </soap:Body>\s*
    </soap:Envelope>
!sx, "Format_Adyen_Authorise_XML");

print "Request:\n$request_xml\n";

my $response_xml = $pg->http_post_xml({
    _url      => $url,
    _username => $username,
    _password => $password,
    _xml      => $request_xml
});

print "Response:\n$response_xml\n";


