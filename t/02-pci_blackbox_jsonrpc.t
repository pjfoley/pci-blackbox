#!/usr/bin/perl
use strict;
use warnings;
no warnings qw(uninitialized);

use Test::More;
use Test::Deep;
use Data::Dumper;
use JSON::RPC::Simple::Client;
use JSON qw(from_json to_json);
use DBI;
use DBIx::Pg::CallFunction;

plan tests => 2;

my $nonpci = JSON::RPC::Simple::Client->new('https://localhost:30001/nonpci');
my $pci    = JSON::RPC::Simple::Client->new('https://localhost:30002/pci');

# Disable verification of SSL-cert in test case
$nonpci->{ua}->ssl_opts(verify_hostname => 0);
$pci->{ua}->ssl_opts(verify_hostname => 0);



# Variables used throughout the test
my $cardnumber              = '5212345678901234';
my $cardexpirymonth         = 06;
my $cardexpiryyear          = 2016;
my $cardholdername          = 'Simon Hopper';
my $currencycode            = 'EUR';
my $paymentamount           = 20;
my $reference               = rand();
my $cardcvc                 = 737;
my $shopperemail            = 'test@test.com';
my $shopperreference        = rand();



# Test 1, Encrypt_Card
my $encrypted_card = $pci->encrypt_card({
    cardnumber      => $cardnumber,
    cardexpirymonth => $cardexpirymonth,
    cardexpiryyear  => $cardexpiryyear,
    cardholdername  => $cardholdername,
    cardissuenumber => undef,
    cardstartmonth  => undef,
    cardstartyear   => undef,
    cardcvc         => $cardcvc
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



# Test 2, Authorise
my $request_authorise = {
    orderid                 => 1234567890,
    currencycode            => $currencycode,
    paymentamount           => $paymentamount,
    cardnumberreference     => $encrypted_card->{cardnumberreference},
    cardkey                 => $encrypted_card->{cardkey},
    cardbin                 => $encrypted_card->{cardbin},
    cardlast4               => $encrypted_card->{cardlast4},
    cvckey                  => $encrypted_card->{cvckey}
};
my $authorise_request = $nonpci->authorise($request_authorise);

cmp_deeply(
    $authorise_request,
    {
        authoriserequestid => re('^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'),
        termurl            => re('^http')
        issuerurl          => re('^http'),
        md                 => re('.+'),
        parequest          => re('.+')
    },
    'Authorise'
);
