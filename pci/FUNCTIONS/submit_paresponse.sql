CREATE OR REPLACE FUNCTION Submit_PaResponse(
OUT RedirectURL text,
_AuthoriseRequestID uuid,
_MD text,
_PaRes text
) RETURNS TEXT AS $BODY$
DECLARE
_OK boolean;
BEGIN
INSERT INTO PaResponses (AuthoriseRequestID, MD, PaRes) VALUES (_AuthoriseRequestID, _MD, _PaRes) RETURNING TRUE INTO STRICT _OK;
RedirectURL := 'https://192.168.35.131:30001/nonpci/authorise_3d?authoriserequestid=' || _AuthoriseRequestID;
RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

REVOKE ALL ON FUNCTION Submit_PaResponse(_AuthoriseRequestID uuid, _MD text, _PaRes text) FROM PUBLIC;
GRANT  ALL ON FUNCTION Submit_PaResponse(_AuthoriseRequestID uuid, _MD text, _PaRes text) TO GROUP pci;
