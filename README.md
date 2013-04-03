# pci-blackbox

PCI-DSS compliant card system built on PostgreSQL and PL/pgSQL

## Installation instructions for Ubuntu 12.04.

Assumes clean OS. Skip packages you already have.

### 1. Install necessary packages
    sudo apt-get install cpanminus build-essential postgresql-9.1 \
    postgresql-contrib-9.1 postgresql-plperl-9.1 libplack-perl libdbd-pg-perl \
    libjson-perl libmodule-install-perl libtest-exception-perl \
    libapache2-mod-perl2 apache2-mpm-prefork git-core libtest-deep-perl \
    libfile-slurp-perl libwww-curl-perl git

### 2. Create a database and database user for our shell user
    sudo -u postgres createuser --no-superuser --no-createrole --createdb $USER
    sudo -u postgres createdb --owner=$USER $USER

### 3. Try to connect
    psql -c "SELECT 'Hello world'"

### 4. Create database user for apache
    sudo -u postgres createuser --no-superuser --no-createrole --no-createdb www-data

### 5. Download and build DBIx::Pg::CallFunction
    cpanm --sudo DBIx::Pg::CallFunction

### 6. Install pci-blackbox
    git clone git://github.com/joelonsql/pci-blackbox.git
    cd pci-blackbox
    # echo "INSERT INTO MerchantAccounts VALUES (?,?,?,?);" > nonpci/populate.sql
    ./install.sh

### 7. Configure pg_service.conf
    sudo cp -n /usr/share/postgresql/9.1/pg_service.conf.sample \
    /etc/postgresql-common/pg_service.conf

    echo "
    [pg_proc_jsonrpc]
    application_name=pg_proc_jsonrpc
    dbname=pci
    " | sudo sh -c 'cat - >> /etc/postgresql-common/pg_service.conf'

### 8. Configure Apache

Add the lines below between `<VirtualHost *:80>` and `</VirtualHost>`
to your sites-enabled file, or to the default file if this
is a new installation, such as `/etc/apache2/sites-enabled/000-default`

    <Location /postgres>
        SetHandler perl-script
        PerlResponseHandler Plack::Handler::Apache2
        PerlSetVar psgi_app /usr/local/bin/pg_proc_jsonrpc.psgi
    </Location>
    <Perl>
        use Plack::Handler::Apache2;
        Plack::Handler::Apache2->preload("/usr/local/bin/pg_proc_jsonrpc.psgi");
    </Perl>

### 9. Restart Apache
    sudo service apache2 restart

### 11. Done!
