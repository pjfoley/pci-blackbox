#!/bin/sh

ARGV="$@"

case $ARGV in
start)
    # Setting PGSERVICEFILE through PerlSetVar does not work because mod_perl
    # unties %ENV from environ[].  This is a bit ugly, but I don't see any
    # better way.  For more information about mod_perl, see
    # http://perl.apache.org/docs/2.0/user/troubleshooting/troubleshooting.html#C_Libraries_Don_t_See_C__ENV__Entries_Set_by_Perl_Code
    env PGSERVICEFILE="`pwd`/pg_service.conf" httpd -d . -f apache-httpd-pci.conf -c "DocumentRoot `pwd`/pci/www_document_root/"
    ERROR=$?
    env PGSERVICEFILE="`pwd`/pg_service.conf" httpd -d . -f apache-httpd-nonpci.conf -c "DocumentRoot `pwd`/nonpci/www_document_root/"
    ERROR=$?
    ;;
stop)
    kill -TERM `cat /tmp/httpd-pci.pid`
    kill -TERM `cat /tmp/httpd-nonpci.pid`
esac

exit $ERROR

