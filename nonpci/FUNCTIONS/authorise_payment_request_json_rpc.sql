CREATE OR REPLACE FUNCTION Authorise_Payment_Request_JSON_RPC(
OUT AuthCode integer,
OUT FraudResult text,
OUT IssuerURL text,
OUT MD text,
OUT PaReq text,
OUT PSPReference text,
OUT RefusalReason text,
OUT ResultCode text,
_PCIBlackBoxURL text,
_CardKey text,
_CVCKey text,
_PSP text,
_MerchantAccount text,
_URL text,
_Username text,
_Password text,
_CurrencyCode char(3),
_PaymentAmount numeric,
_Reference text,
_ShopperIP inet,
_ShopperEmail text,
_ShopperReference text,
_FraudOffset integer,
_SelectedBrand text,
_BrowserInfoAcceptHeader text,
_BrowserInfoUserAgent text
) RETURNS RECORD AS $BODY$

my ($PCIBlackBoxURL, $CardKey, $CVCKey, $PSP, $MerchantAccount, $URL, $Username, $Password, $CurrencyCode, $PaymentAmount, $Reference, $ShopperIP, $ShopperEmail, $ShopperReference, $FraudOffset, $SelectedBrand, $BrowserInfoAcceptHeader, $BrowserInfoUserAgent) = @_;

use JSON::RPC::Simple::Client;
my $c = JSON::RPC::Simple::Client->new($PCIBlackBoxURL);

if ($PCIBlackBoxURL =~ m!^https://localhost!i) {
    # Test-environment or local call, skip check
    $c->{ua}->ssl_opts(verify_hostname => 0);
}

my $r = $c->authorise_payment_request({
    cardkey                 => $CardKey,
    cvckey                  => $CVCKey,
    psp                     => $PSP,
    merchantaccount         => $MerchantAccount,
    url                     => $URL,
    username                => $Username,
    password                => $Password,
    currencycode            => $CurrencyCode,
    paymentamount           => $PaymentAmount,
    reference               => $Reference,
    shopperip               => $ShopperIP,
    shopperemail            => $ShopperEmail,
    shopperreference        => $ShopperReference,
    fraudoffset             => $FraudOffset,
    selectedbrand           => $SelectedBrand,
    browserinfoacceptheader => $BrowserInfoAcceptHeader,
    browserinfouseragent    => $BrowserInfoUserAgent
});
return $r;
$BODY$ LANGUAGE plperlu VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Authorise_Payment_Request_JSON_RPC(_PCIBlackBoxURL text, _CardKey text, _CVCKey text, _PSP text, _MerchantAccount text, _URL text, _Username text, _Password text, _CurrencyCode char(3), _PaymentAmount numeric, _Reference text, _ShopperIP inet, _ShopperEmail text, _ShopperReference text, _FraudOffset integer, _SelectedBrand text, _BrowserInfoAcceptHeader text, _BrowserInfoUserAgent text) FROM PUBLIC;
GRANT  ALL ON FUNCTION Authorise_Payment_Request_JSON_RPC(_PCIBlackBoxURL text, _CardKey text, _CVCKey text, _PSP text, _MerchantAccount text, _URL text, _Username text, _Password text, _CurrencyCode char(3), _PaymentAmount numeric, _Reference text, _ShopperIP inet, _ShopperEmail text, _ShopperReference text, _FraudOffset integer, _SelectedBrand text, _BrowserInfoAcceptHeader text, _BrowserInfoUserAgent text) TO GROUP nonpci;
