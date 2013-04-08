CREATE OR REPLACE FUNCTION Authorise_Payment_Request_JSON_RPC(
OUT AuthCode integer,
OUT DCCAmount numeric,
OUT DCCSignature text,
OUT FraudResult text,
OUT IssuerURL text,
OUT MD text,
OUT PARequest text,
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
_BrowserInfoUserAgent text,
_HashSalt text
) RETURNS RECORD AS $BODY$

my ($PCIBlackBoxURL, $CardKey, $CVCKey, $PSP, $MerchantAccount, $URL, $Username, $Password, $CurrencyCode, $PaymentAmount, $Reference, $ShopperIP, $ShopperEmail, $ShopperReference, $FraudOffset, $SelectedBrand, $BrowserInfoAcceptHeader, $BrowserInfoUserAgent, $HashSalt) = @_;

use JSON::RPC::Simple::Client;
my $c = JSON::RPC::Simple::Client->new($PCIBlackBoxURL);
my $r = $c->authorise_payment_request({
    _cardkey                 => $CardKey,
    _cvckey                  => $CVCKey,
    _psp                     => $PSP,
    _merchantaccount         => $MerchantAccount,
    _url                     => $URL,
    _username                => $Username,
    _password                => $Password,
    _currencycode            => $CurrencyCode,
    _paymentamount           => $PaymentAmount,
    _reference               => $Reference,
    _shopperip               => $ShopperIP,
    _shopperemail            => $ShopperEmail,
    _shopperreference        => $ShopperReference,
    _fraudoffset             => $FraudOffset,
    _selectedbrand           => $SelectedBrand,
    _browserinfoacceptheader => $BrowserInfoAcceptHeader,
    _browserinfouseragent    => $BrowserInfoUserAgent,
    _hashsalt                => $HashSalt
});
return $r;
$BODY$ LANGUAGE plperlu VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Authorise_Payment_Request_JSON_RPC(_PCIBlackBoxURL text, _CardKey text, _CVCKey text, _PSP text, _MerchantAccount text, _URL text, _Username text, _Password text, _CurrencyCode char(3), _PaymentAmount numeric, _Reference text, _ShopperIP inet, _ShopperEmail text, _ShopperReference text, _FraudOffset integer, _SelectedBrand text, _BrowserInfoAcceptHeader text, _BrowserInfoUserAgent text, _HashSalt text) FROM PUBLIC;
GRANT  ALL ON FUNCTION Authorise_Payment_Request_JSON_RPC(_PCIBlackBoxURL text, _CardKey text, _CVCKey text, _PSP text, _MerchantAccount text, _URL text, _Username text, _Password text, _CurrencyCode char(3), _PaymentAmount numeric, _Reference text, _ShopperIP inet, _ShopperEmail text, _ShopperReference text, _FraudOffset integer, _SelectedBrand text, _BrowserInfoAcceptHeader text, _BrowserInfoUserAgent text, _HashSalt text) TO "nonpci";
