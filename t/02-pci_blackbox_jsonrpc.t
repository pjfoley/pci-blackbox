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

plan tests => 6;

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
        termurl            => re('^http'),
        issuerurl          => re('^http'),
        md                 => re('.+'),
        parequest          => re('.+'),
        resultcode         => 'RedirectShopper'
    },
    'Authorise'
);



# Test 3, HTTPS POST issuer URL, load password form
my $ua = LWP::UserAgent->new();
my $http_response_load_password_form = $ua->post($authorise_request->{issuerurl}, {
    PaReq   => $authorise_request->{parequest},
    TermUrl => 'https://foo.bar.com/',
    MD      => $authorise_request->{md}
});
ok($http_response_load_password_form->is_success, "HTTPS POST issuer URL, load password form");



# Test 4, HTTPS POST issuer URL, submit password
my $http_response_submit_password = $ua->post('https://test.adyen.com/hpp/3d/authenticate.shtml', {
    PaReq      => $authorise_request->{parequest},
    TermUrl    => 'https://foo.bar.com/',
    MD         => $authorise_request->{md},
    cardNumber => $cardnumber,
    username   => 'user',
    password   => 'password'
});
ok($http_response_submit_password->is_success, "HTTPS POST issuer URL, submit password");



# Test 5, HTTPS POST issuer URL, parsed PaRes
if ($http_response_submit_password->decoded_content =~ m/<input type="hidden" name="PaRes" value="([^"]+)"/) {
    ok(1,"HTTPS POST issuer URL, parsed PaRes");
}
my $pares = $1;




# Test 6, Authorise_3D
my $request_3d = {
    authoriserequestid => $authorise_request->{authoriserequestid},
    MD                 => $authorise_request->{md},
    PaRes              => $pares,
};
my $response_3d = $nonpci->authorise_3d($request_3d);
like($response_3d, qr/^http/, 'Authorise_3D');
