pci-blackbox
============

PCI-DSS compliant card system built on PostgreSQL and PL/pgSQL

1. Installation instructions.
Assumes clean OS. Skip packages you already have.

1.1. Ubuntu 12.04

1.1.1. Install necessary packages
sudo apt-get install cpanminus build-essential postgresql-9.1 postgresql-contrib-9.1 postgresql-plperl-9.1 libplack-perl libdbd-pg-perl libjson-perl libmodule-install-perl libtest-exception-perl libapache2-mod-perl2 apache2-mpm-prefork git-core libtest-deep-perl libfile-slurp-perl libwww-curl-perl

1.1.2. Create a database and database user for our shell user
sudo -u postgres createuser --superuser $USER
sudo -u postgres createdb --owner=$USER $USER

1.1.3. Try to connect
psql -c "SELECT 'Hello world'"

1.1.4. Create database user for apache
sudo -u postgres createuser --no-superuser --no-createrole --no-createdb www-data

1.1.5. Download and build DBIx::Pg::CallFunction
cpanm --sudo DBIx::Pg::CallFunction

1.1.6. Grant access to connect to our database
psql -c "GRANT CONNECT ON DATABASE $USER TO \"www-data\""

1.1.7. Configure pg_service.conf
# copy sample config
sudo cp -n /usr/share/postgresql/9.1/pg_service.conf.sample /etc/postgresql-common/pg_service.conf

echo "
[pg_proc_jsonrpc]
application_name=pg_proc_jsonrpc
dbname=$USER
" | sudo sh -c 'cat - >> /etc/postgresql-common/pg_service.conf'

1.1.8. Configure Apache
# Add the lines below between <VirtualHost *:80> and </VirtualHost>
# to your sites-enabled file, or to the default file if this
# is a new installation.

# /etc/apache2/sites-enabled/000-default
<Location /postgres>
  SetHandler perl-script
  PerlResponseHandler Plack::Handler::Apache2
  PerlSetVar psgi_app /usr/local/bin/pg_proc_jsonrpc.psgi
</Location>
<Perl>
  use Plack::Handler::Apache2;
  Plack::Handler::Apache2->preload("/usr/local/bin/pg_proc_jsonrpc.psgi");
</Perl>

1.1.9. Restart Apache
sudo service apache2 restart

1.1.10. Clone pci-blackbox repo
git clone git://github.com/joelonsql/pci-blackbox.git

1.1.11. Install pci-blackbox
cd pci-blackbox
echo "INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password) VALUES ('Adyen', 'YourCompanyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompanyInc', 's3cr3tp4ssw0rd');" > nonpci/populate.sql
./install.sh

Done!
