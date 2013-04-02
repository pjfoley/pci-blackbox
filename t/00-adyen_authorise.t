#!/usr/bin/perl
use strict;
use warnings;
no warnings qw(uninitialized);

use DBI;
use DBIx::Pg::CallFunction;
use Test::More;
use Test::Deep;
use Data::Dumper;
plan tests => 3;

# Connect to the PCI compliant service
my $dbh_pci = DBI->connect("dbi:Pg:dbname=pci", '', '', {pg_enable_utf8 => 1, PrintError => 0});
my $pci = DBIx::Pg::CallFunction->new($dbh_pci);

# Connect to the non-PCI compliant service
my $dbh = DBI->connect("dbi:Pg:dbname=nonpci", '', '', {pg_enable_utf8 => 1, PrintError => 0});
my $nonpci = DBIx::Pg::CallFunction->new($dbh);

my $merchant_account = $nonpci->get_merchant_account();
cmp_deeply(
    $merchant_account,
    {
        psp             => re('.+'),
        merchantaccount => re('.+'),
        url             => re('^https://'),
        username        => re('.+'),
        password        => re('.+'),
        hashsalt        => re('.+')
    },
    'Get_Merchant_Account'
);

my $order = {
    _merchantaccount         => $merchant_account->{merchantaccount},
    _currencycode            => 'EUR',
    _paymentamount           => 2000,
    _reference               => 'Your Reference Here',
    _shopperip               => '61.249.12.12',
    _cardcvc                 => 737,
    _shopperemail            => 's.hopper@test.com',
    _shopperreference        => 'Simon Hopper',
    _cardnumber              => 4111111111111111,
    _cardexpirymonth         => 06,
    _cardexpiryyear          => 2016,
    _cardholdername          => 'Adyen Test',
    _browserinfoacceptheader => 'text/html,application/xhtml+xml, application/xml;q=0.9,*/*;q=0.8',
    _browserinfouseragent    => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008052912 Firefox/3.0'
};


my $request_xml = $pci->format_adyen_authorise_request($order);

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
                    <browserInfo\ xmlns="http://payment\.services\.adyen\.com">\s*
                        <acceptHeader\ xmlns="http://common\.services\.adyen\.com">\Q$order->{_browserinfoacceptheader}\E</acceptHeader>\s*
                        <userAgent\ xmlns="http://common\.services\.adyen\.com">\Q$order->{_browserinfouseragent}\E</userAgent>\s*
                    </browserInfo>\s*
                    <merchantAccount\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_merchantaccount}\E</merchantAccount>\s*
                    <reference\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_reference}\E</reference>\s*
                    <shopperEmail\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_shopperemail}\E</shopperEmail>\s*
                    <shopperIP\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_shopperip}\E</shopperIP>\s*
                    <shopperReference\ xmlns="http://payment\.services\.adyen\.com">\Q$order->{_shopperreference}\E</shopperReference>\s*
                </ns1:paymentRequest>\s*
            </ns1:authorise>\s*
        </soap:Body>\s*
    </soap:Envelope>
!sx, "Format_Adyen_Authorise_Request");

my $response_xml = $pci->http_post_xml({
    _url      => $merchant_account->{url},
    _username => $merchant_account->{username},
    _password => $merchant_account->{password},
    _xml      => $request_xml
});

my $response = $pci->parse_adyen_authorise_response({
    _xml => $response_xml
});

cmp_deeply(
    $response,
    {
        'dccamount'     => undef,
        'md'            => undef,
        'authcode'      => re('^\d+$'),
        'dccsignature'  => undef,
        'fraudresult'   => undef,
        'parequest'     => undef,
        'refusalreason' => undef,
        'issuerurl'     => undef,
        'resultcode'    => 'Authorised',
        'pspreference'  => re('^\d+$')
    },
    'Parse_Adyen_Authorise_Response'
);

