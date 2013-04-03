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
plan tests => 13;

# Connect to the PCI compliant service
my $dbh_pci = DBI->connect("dbi:Pg:dbname=pci", '', '', {pg_enable_utf8 => 1, PrintError => 0});
my $pci = DBIx::Pg::CallFunction->new($dbh_pci);

# Connect to the non-PCI compliant service
my $dbh = DBI->connect("dbi:Pg:dbname=nonpci", '', '', {pg_enable_utf8 => 1, PrintError => 0});
my $nonpci = DBIx::Pg::CallFunction->new($dbh);

# We will never COMMIT, so this means ROLLBACK automatically in the end.
$dbh_pci->begin_work();
$dbh->begin_work();

my $cardnumber              = '4111111111111111';
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

# Store sensitive card data encrypted to the
# PCI-DSS compliant protected component
my $encrypted_card = $pci->encrypt_card({
    _cardnumber      => $cardnumber,
    _cardexpirymonth => $cardexpirymonth,
    _cardexpiryyear  => $cardexpiryyear,
    _cardholdername  => $cardholdername,
    _cardissuenumber => undef,
    _cardstartmonth  => undef,
    _cardstartyear   => undef,
    _hashsalt        => $merchant_account->{hashsalt}
});

cmp_deeply(
    $encrypted_card,
    {
        cardnumberreference => re('^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'),
        cardkey             => re('^[0-9a-f]{512}$'),
        cardbin             => re('^[0-9]{6}$'),
        cardlast4           => re('^[0-9]{4}$')
    },
    'Encrypt_Card, non-3D Secure enrolled card'
);

my $cvckey = $pci->encrypt_cvc({_cardcvc => $cardcvc});
like($cvckey,qr/^[0-9a-f]{512}$/,"Encrypt_CVC, non-3D Secure enrolled card");

my $cardid = $nonpci->store_card_key({
    _cardnumberreference => $encrypted_card->{cardnumberreference},
    _cardkey             => $encrypted_card->{cardkey},
    _cardbin             => $encrypted_card->{cardbin},
    _cardlast4           => $encrypted_card->{cardlast4}
});
cmp_ok($cardid,'>=',1,"Store_Card_Key, non-3D Secure enrolled card");

my $request = {
    _cardkey                 => $encrypted_card->{cardkey},
    _cvckey                  => $cvckey,
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

# Use the card by passing the CardKey
# along with the payment information
my $response = $pci->authorise_payment_request($request);

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
    'Authorise_Payment_Request, non-3D Secure enrolled card'
);

# 3D Secure test card

# Store sensitive card data encrypted to the
# PCI-DSS compliant protected component
$cardnumber = '5212345678901234';
$encrypted_card = $pci->encrypt_card({
    _cardnumber      => $cardnumber,
    _cardexpirymonth => $cardexpirymonth,
    _cardexpiryyear  => $cardexpiryyear,
    _cardholdername  => $cardholdername,
    _cardissuenumber => undef,
    _cardstartmonth  => undef,
    _cardstartyear   => undef,
    _hashsalt        => $merchant_account->{hashsalt}
});

cmp_deeply(
    $encrypted_card,
    {
        cardnumberreference => re('^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'),
        cardkey             => re('^[0-9a-f]{512}$'),
        cardbin             => re('^[0-9]{6}$'),
        cardlast4           => re('^[0-9]{4}$')
    },
    'Encrypt_Card, 3D Secure enrolled card'
);
$cvckey = $pci->encrypt_cvc({_cardcvc => $cardcvc});
like($cvckey,qr/^[0-9a-f]{512}$/,"Encrypt_CVC, 3D Secure enrolled card");

$cardid = $nonpci->store_card_key({
    _cardnumberreference => $encrypted_card->{cardnumberreference},
    _cardkey             => $encrypted_card->{cardkey},
    _cardbin             => $encrypted_card->{cardbin},
    _cardlast4           => $encrypted_card->{cardlast4}
});
cmp_ok($cardid,'>=',1,"Store_Card_Key, 3D Secure enrolled card");

$request = {
    _cardkey                 => $encrypted_card->{cardkey},
    _cvckey                  => $cvckey,
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

$response = $pci->authorise_payment_request($request);

cmp_deeply(
    $response,
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
    'Authorise_Payment_Request, 3D Secure enrolled card'
);

my $ua = LWP::UserAgent->new();
my $http_response = $ua->post($response->{issuerurl}, {
    PaReq   => $response->{parequest},
    TermUrl => 'https://foo.bar.com/',
    MD      => $response->{md}
});
ok($http_response->is_success, "POST issuer URL, load password form");

$http_response = $ua->post('https://test.adyen.com/hpp/3d/authenticate.shtml', {
    PaReq      => $response->{parequest},
    TermUrl    => 'https://foo.bar.com/',
    MD         => $response->{md},
    cardNumber => $cardnumber,
    username   => 'user',
    password   => 'password'
});
ok($http_response->is_success, "POST issuer URL, submit password");

if ($http_response->decoded_content =~ m/<input type="hidden" name="PaRes" value="([^"]+)"/) {
    ok(1,"POST issuer URL, parsed PaRes");
}
my $pares = $1;

$request = {
    _psp                     => $merchant_account->{psp},
    _merchantaccount         => $merchant_account->{merchantaccount},
    _url                     => $merchant_account->{url},
    _username                => $merchant_account->{username},
    _password                => $merchant_account->{password},
    _browserinfoacceptheader => $browserinfoacceptheader,
    _browserinfouseragent    => $browserinfouseragent,
    _issuermd                => $response->{md},
    _issuerparesponse        => $pares,
    _shopperip               => $shopperip
};

$response = $pci->authorise_payment_request_3d($request);

cmp_deeply(
    $response,
    {
        'pspreference'  => re('^\d+$'),
        'resultcode'    => 'Authorised',
        'authcode'      => re('^\d+$'),
        'refusalreason' => undef
    },
    'Authorise_Payment_Request_3D, submit PaRes'
);

$dbh->rollback;
$dbh_pci->rollback;
