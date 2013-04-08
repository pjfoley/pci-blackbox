#!/usr/bin/perl
use strict;
use warnings;
no warnings qw(uninitialized);

use DBI;
use DBIx::Pg::CallFunction;
use Test::More;
use Test::Deep;
use Data::Dumper;
use LWP::UserAgent;
use File::Slurp qw(write_file);

plan tests => 8;

# Connect to the isolated PCI compliant pci-blackbox
my $dbh_pci = DBI->connect("dbi:Pg:dbname=pci", 'pci', '', {pg_enable_utf8 => 1, PrintError => 0});
my $pci = DBIx::Pg::CallFunction->new($dbh_pci);

# Connect to the normal database
my $dbh = DBI->connect("dbi:Pg:dbname=nonpci", 'nonpci', '', {pg_enable_utf8 => 1, PrintError => 0});
my $nonpci = DBIx::Pg::CallFunction->new($dbh);



# Variables used throughout the test
my $cardnumber              = '5212345678901234';
my $cardexpirymonth         = 06;
my $cardexpiryyear          = 2016;
my $cardholdername          = 'Simon Hopper';
my $currencycode            = 'EUR';
my $paymentamount           = 20;
my $reference               = rand();
my $shopperip               = '1.2.3.4';
my $cardcvc                 = 737;
my $shopperemail            = 'test@test.com';
my $shopperreference        = rand();
my $fraudoffset             = undef;
my $selectedbrand           = undef;
my $browserinfoacceptheader = 'text/html,application/xhtml+xml, application/xml;q=0.9,*/*;q=0.8';
my $browserinfouseragent    = 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008052912 Firefox/3.0';



# BEGIN (will ROLLBACK in the end of test)
$dbh_pci->begin_work();
$dbh->begin_work();



# Test 1, Get_Merchant_Account
my $merchant_account = $nonpci->get_merchant_account();
cmp_deeply(
    $merchant_account,
    {
        psp             => re('.+'),
        merchantaccount => re('.+'),
        url             => re('^https://'),
        username        => re('.+'),
        password        => re('.+')
    },
    'Get_Merchant_Account'
);



# Test 2, Encrypt_Card
my $encrypted_card = $pci->encrypt_card({
    _cardnumber      => $cardnumber,
    _cardexpirymonth => $cardexpirymonth,
    _cardexpiryyear  => $cardexpiryyear,
    _cardholdername  => $cardholdername,
    _cardissuenumber => undef,
    _cardstartmonth  => undef,
    _cardstartyear   => undef,
    _cardcvc         => $cardcvc
});
cmp_deeply(
    $encrypted_card,
    {
        cardnumberreference => re('^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'),
        cardkey             => re('^[0-9a-f]{512}$'),
        cardbin             => re('^[0-9]{6}$'),
        cardlast4           => re('^[0-9]{4}$'),
        cvckey              => re('^[0-9a-f]{512}$')
    },
    'Encrypt_Card'
);



# Test 3, Store_Card_Key
my $cardid = $nonpci->store_card_key({
    _cardnumberreference => $encrypted_card->{cardnumberreference},
    _cardkey             => $encrypted_card->{cardkey},
    _cardbin             => $encrypted_card->{cardbin},
    _cardlast4           => $encrypted_card->{cardlast4}
});
cmp_ok($cardid,'>=',1,"Store_Card_Key");



# Test 4, Authorise_Payment_Request
my $request = {
    _cardkey                 => $encrypted_card->{cardkey},
    _cvckey                  => $encrypted_card->{cvckey},
    _psp                     => $merchant_account->{psp},
    _merchantaccount         => $merchant_account->{merchantaccount},
    _url                     => $merchant_account->{url},
    _username                => $merchant_account->{username},
    _password                => $merchant_account->{password},
    _currencycode            => $currencycode,
    _paymentamount           => $paymentamount,
    _reference               => $reference,
    _shopperip               => $shopperip,
    _shopperemail            => $shopperemail,
    _shopperreference        => $shopperreference,
    _fraudoffset             => $fraudoffset,
    _selectedbrand           => $selectedbrand,
    _browserinfoacceptheader => $browserinfoacceptheader,
    _browserinfouseragent    => $browserinfouseragent
};
my $authorise_payment_response = $pci->authorise_payment_request($request);
cmp_deeply(
    $authorise_payment_response,
    {
        'dccamount'     => undef,
        'md'            => re('^[a-zA-Z0-9/+=]+$'),
        'authcode'      => undef,
        'dccsignature'  => undef,
        'fraudresult'   => undef,
        'parequest'     => re('^[a-zA-Z0-9/+=]+$'),
        'refusalreason' => undef,
        'issuerurl'     => re('^https://'),
        'resultcode'    => 'RedirectShopper',
        'pspreference'  => re('^\d+$')
    },
    'Authorise_Payment_Request'
);



# Test 5, HTTPS POST issuer URL, load password form
my $ua = LWP::UserAgent->new();
my $http_response_load_password_form = $ua->post($authorise_payment_response->{issuerurl}, {
    PaReq   => $authorise_payment_response->{parequest},
    TermUrl => 'https://foo.bar.com/',
    MD      => $authorise_payment_response->{md}
});
ok($http_response_load_password_form->is_success, "HTTPS POST issuer URL, load password form");



# Test 6, HTTPS POST issuer URL, submit password
my $http_response_submit_password = $ua->post('https://test.adyen.com/hpp/3d/authenticate.shtml', {
    PaReq      => $authorise_payment_response->{parequest},
    TermUrl    => 'https://foo.bar.com/',
    MD         => $authorise_payment_response->{md},
    cardNumber => $cardnumber,
    username   => 'user',
    password   => 'password'
});
ok($http_response_submit_password->is_success, "HTTPS POST issuer URL, submit password");



# Test 7, HTTPS POST issuer URL, parsed PaRes
if ($http_response_submit_password->decoded_content =~ m/<input type="hidden" name="PaRes" value="([^"]+)"/) {
    ok(1,"HTTPS POST issuer URL, parsed PaRes");
}
my $pares = $1;



# Test 8, Authorise_Payment_Request_3D
my $request_3d = {
    _psp                     => $merchant_account->{psp},
    _merchantaccount         => $merchant_account->{merchantaccount},
    _url                     => $merchant_account->{url},
    _username                => $merchant_account->{username},
    _password                => $merchant_account->{password},
    _browserinfoacceptheader => $browserinfoacceptheader,
    _browserinfouseragent    => $browserinfouseragent,
    _issuermd                => $authorise_payment_response->{md},
    _issuerparesponse        => $pares,
    _shopperip               => $shopperip
};
my $response_3d = $pci->authorise_payment_request_3d($request_3d);
cmp_deeply(
    $response_3d,
    {
        'pspreference'  => re('^\d+$'),
        'resultcode'    => 'Authorised',
        'authcode'      => re('^\d+$'),
        'refusalreason' => undef
    },
    'Authorise_Payment_Request_3D'
);



$dbh->commit;
$dbh_pci->commit;
