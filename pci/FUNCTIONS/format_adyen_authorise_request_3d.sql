CREATE OR REPLACE FUNCTION Format_Adyen_Authorise_Request_3D(
_BrowserInfoAcceptHeader text,
_BrowserInfoUserAgent text,
_MD text,
_MerchantAccount text,
_PaRes text,
_ShopperIP inet
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
            name "ns1:authorise3d",
            xmlattributes('http://payment.services.adyen.com' AS "xmlns:ns1"),
            xmlelement(
                name "ns1:paymentRequest3d",
                xmlelement(
                    name "browserInfo",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    xmlelement(
                        name "acceptHeader",
                        xmlattributes('http://common.services.adyen.com' AS "xmlns"),
                        _BrowserInfoAcceptHeader
                    ),
                    xmlelement(
                        name "userAgent",
                        xmlattributes('http://common.services.adyen.com' AS "xmlns"),
                        _BrowserInfoUserAgent
                    )
                ),
                xmlelement(
                    name "md",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _MD
                ),
                xmlelement(
                    name "merchantAccount",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _MerchantAccount
                ),
                xmlelement(
                    name "paResponse",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _PaRes
                ),
                xmlelement(
                    name "shopperIP",
                    xmlattributes('http://payment.services.adyen.com' AS "xmlns"),
                    _ShopperIP
                )
            )
        )
    )
);
END;
$BODY$ LANGUAGE plpgsql;
