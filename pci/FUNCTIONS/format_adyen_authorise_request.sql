CREATE OR REPLACE FUNCTION Format_Adyen_Authorise_Request(
_MerchantAccount text,
_CurrencyCode char(3),
_PaymentAmount numeric,
_Reference text,
_ShopperIP inet,
_CardCVC text,
_ShopperEmail text,
_ShopperReference text,
_CardNumber text,
_CardExpiryMonth integer,
_CardExpiryYear integer,
_CardHolderName text,
_HTTP_ACCEPT text,
_HTTP_USER_AGENT text
) RETURNS xml AS $BODY$
DECLARE
BEGIN

RETURN xmlelement(
    name "soap:Envelope",
    xmlattributes(
        'http://schemas.xmlsoap.org/soap/envelope/' AS "xmlns:soap",
        'http://www.w3.org/2001/XMLSchema' AS "xmlns:xsd",
        'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi"
    ),
    xmlelement(
        name "soap:Body",
        xmlelement(
            name "ns1:authorise",
            xmlattributes('http://payment.services.adyen.com' AS "xmlns:ns1"),
            xmlelement(
                name "ns1:paymentRequest",
                xmlelement(
                    name "amount",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    xmlelement(
                        name "currency",
                        xmlattributes('http://common.services.adyen.com' AS "xmlns"),
                        _CurrencyCode
                    ),
                    xmlelement(
                        name "value",
                        xmlattributes('http://common.services.adyen.com' AS "xmlns"),
                        _PaymentAmount
                    )
                ),
                xmlelement(
                    name "card",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    xmlelement(
                        name "cvc",
                        _CardCVC
                    ),
                    xmlelement(
                        name "expiryMonth",
                        _CardExpiryMonth
                    ),
                    xmlelement(
                        name "expiryYear",
                        _CardExpiryYear
                    ),
                    xmlelement(
                        name "holderName",
                        _CardHolderName
                    ),
                    xmlelement(
                        name "number",
                        _CardNumber
                    )
                ),
                xmlelement(
                    name "browserInfo",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    xmlelement(
                        name "acceptHeader",
                        xmlattributes('http://common.services.adyen.com' AS "xmlns"),
                        _HTTP_ACCEPT
                    ),
                    xmlelement(
                        name "userAgent",
                        xmlattributes('http://common.services.adyen.com' AS "xmlns"),
                        _HTTP_USER_AGENT
                    )
                ),
                xmlelement(
                    name "merchantAccount",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _MerchantAccount
                ),
                xmlelement(
                    name "reference",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _Reference
                ),
                xmlelement(
                    name "shopperEmail",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _ShopperEmail
                ),
                xmlelement(
                    name "shopperIP",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _ShopperIP
                ),
                xmlelement(
                    name "shopperReference",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _ShopperReference
                )
            )
        )
    )
);
END;
$BODY$ LANGUAGE plpgsql;
