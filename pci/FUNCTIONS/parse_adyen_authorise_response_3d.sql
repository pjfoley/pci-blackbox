CREATE OR REPLACE FUNCTION Parse_Adyen_Authorise_Response_3D(
OUT AuthCode integer,
OUT IssuerURL text,
OUT MD text,
OUT PaReq text,
OUT PSPReference text,
OUT ResultCode text,
_XML xml
) RETURNS RECORD AS $BODY$
DECLARE
_ xml[];
_BasePath text;
_PaymentResult xml;
_NSArray text[];
BEGIN
_NSArray := ARRAY[
    ['soap', 'http://schemas.xmlsoap.org/soap/envelope/'],
    ['xsd','http://www.w3.org/2001/XMLSchema'],
    ['xsi','http://www.w3.org/2001/XMLSchema-instance'],
    ['ns1','http://payment.services.adyen.com']
];

_BasePath := '/soap:Envelope/soap:Body/ns1:authorise3dResponse/ns1:paymentResult/ns1:';

AuthCode      := (xpath(_BasePath || 'authCode/text()',     _XML,_NSArray))[1]::text;
IssuerURL     := (xpath(_BasePath || 'issuerUrl/text()',    _XML,_NSArray))[1]::text;
MD            := (xpath(_BasePath || 'md/text()',           _XML,_NSArray))[1]::text;
PaReq         := (xpath(_BasePath || 'paRequest/text()',    _XML,_NSArray))[1]::text;
PSPReference  := (xpath(_BasePath || 'pspReference/text()', _XML,_NSArray))[1]::text;
ResultCode    := (xpath(_BasePath || 'resultCode/text()',   _XML,_NSArray))[1]::text;

RETURN;
END;
$BODY$ LANGUAGE plpgsql;
