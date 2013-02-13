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

my $psp                     = 'Adyen';
my $merchantaccount         = 'TrustlyCOM';
my $cardnumber              = '4111111111111111';
my $cardexpirymonth         = 12;
my $cardexpiryyear          = 2012;
my $cardholdername          = 'Simon Hopper';
my $currencycode            = 'EUR';
my $paymentamount           = 2000;
my $reference               = 'Your Reference Here';
my $shopperip               = '61.249.12.12';
my $cardcvc                 = 737;
my $shopperemail            = 's.hopper@test.com';
my $shopperreference        = 'Simon Hopper';
my $fraudoffset             = undef;
my $selectedbrand           = undef;
my $browserinfoacceptheader = 'text/html,application/xhtml+xml, application/xml;q=0.9,*/*;q=0.8';
my $browserinfouseragent    = 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008052912 Firefox/3.0';

my $credentials = $nonpci->get_merchant_account({_psp => $psp, _merchantaccount => $merchantaccount});
cmp_deeply(
    $credentials,
    {
        url      => re('^https://'),
        username => re('.+'),
        password => re('.+')
    },
    'Get_Merchant_Account'
);

# Store sensitive card data encrypted to the
# PCI-DSS compliant protected component
my $cardkey = $pci->encrypt_card({
    _cardnumber      => $cardnumber,
    _cardexpirymonth => $cardexpirymonth,
    _cardexpiryyear  => $cardexpiryyear,
    _cardholdername  => $cardholdername,
    _cardissuenumber => undef,
    _cardstartmonth  => undef,
    _cardstartyear   => undef
});
like($cardkey,qr/^[0-9a-f]{512}$/,'Encrypt_Card');

# Use the card by passing the CardKey
# along with the payment information
my $response = $pci->authorise_payment_request({
    _cardkey                 => $cardkey,
    _psp                     => $psp,
    _merchantaccount         => $merchantaccount,
    _url                     => $credentials->{url},
    _username                => $credentials->{username},
    _password                => $credentials->{password},
    _currencycode            => $currencycode,
    _paymentamount           => $paymentamount,
    _reference               => $reference,
    _shopperip               => $shopperip,
    _cardcvc                 => $cardcvc,
    _shopperemail            => $shopperemail,
    _shopperreference        => $shopperreference,
    _fraudoffset             => $fraudoffset,
    _selectedbrand           => $selectedbrand,
    _browserinfoacceptheader => $browserinfoacceptheader,
    _browserinfouseragent    => $browserinfouseragent
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
    'Authorise_Payment_Request'
);

