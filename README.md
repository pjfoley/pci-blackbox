# pci-blackbox

PCI-DSS compliant card system built on PostgreSQL and PL/pgSQL

## Installation instructions for Ubuntu 12.04.

Assumes clean OS. Skip packages you already have.

### 1. Install necessary packages
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install cpanminus build-essential postgresql-9.1 \
    postgresql-contrib-9.1 postgresql-plperl-9.1 libplack-perl libdbd-pg-perl \
    libjson-perl libmodule-install-perl libtest-exception-perl \
    libapache2-mod-perl2 apache2-mpm-prefork git-core libtest-deep-perl \
    libfile-slurp-perl libwww-curl-perl git libdbix-connector-perl

### 2. Download and build Perl modules not in the Ubuntu repo
    cpanm --sudo DBIx::Pg::CallFunction JSON::RPC::Simple::Client

### 3. Aquire test account from any of the supported PSPs, currently only Adyen.

### 4. Insert the merchant account test credentials into the file nonpci/populate.sql
	# echo "INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password, PCIBlackBoxURL) \
	# VALUES ('Adyen', 'TrustlyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompany', 'yourpassword', 'https://localhost:30002/pci');"\
	# > nonpci/populate.sql

### 5. Install pci-blackbox
    git clone git://github.com/joelonsql/pci-blackbox.git
    cd pci-blackbox
    sudo -u postgres psql -f install.sql
    sudo sh -c 'cat pg_service.conf >> /etc/postgresql-common/pg_service.conf'
	perl Makefile.PL && make && sudo make install
	sudo cp sites-available/pci-ssl /etc/apache2/sites-available/pci-ssl
	sudo cp sites-available/nonpci-ssl /etc/apache2/sites-available/nonpci-ssl
    sudo sh -c 'cat ports.conf >> /etc/apache2/ports.conf'
    sudo sh -c 'echo ServerName localhost >> /etc/apache2/httpd.conf'
	sudo a2enmod perl ssl
	sudo a2ensite pci-ssl nonpci-ssl
	sudo service apache2 restart
    sudo -u www-data prove

