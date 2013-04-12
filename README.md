# pci-blackbox

PCI-DSS compliant system built on PostgreSQL and PL/pgSQL

This module aims to simplify the process of becoming PCI-DSS compliant,
by handling card data in an isolated system, physically and logically
separated from the rest of the system.

![layout](https://raw.github.com/joelonsql/pci-blackbox/master/doc/pci-blackbox.png)

The idea comes from a guy I met over a beer who works at Skype.
He explained they had done something similar,
they have/had a special "PCI server" kept secure behind locked doors,
which only function was to encrypt/decrypt/process card data.

I thought it sounded like a smart idea, for merchants who for some reason
need to become PCI-DSS compliant and cannot use a hosted payment solution.

The company I work for is in the process of implementing card payments,
and we cannot use a hosted solution, so we decided to give this concept a shot,
and see if we managed to come up with something useful.
Hopefully we have, you be the judge.

The pci-blackbox must be run on a separate server from the main system.
In this test however, everything is being run on the same machine.

The API consist of three functions:

- encrypt_card(): Encrypt sensitive card data, return a CardKey.

- authorise_payment_request(): Authorise payment using a CardKey.

- authorise_payment_request_3d(): Authorise 3-D Secure payment.

Highlights:

- 3-D Secure support

- Gateway-independent, like Spreedly, the API is generic, not specific to any gateway, currently only Adyen is supported though.

- Host your own payment page, like Stripe, you design your own payment page, and POST directly to the pci-blackbox.

- PCI-DSS compliant.

- Open sourced under the MIT-license

This module is **work in progress** and has not been put into production yet.

If anyone know of any other similar open source project, which provides
an isolated card-component, please let me know. Couldn't find any,
so that's why I started hacking on this.

The files under /nonpci are just an example implementation
on how to use the pci-blackbox.

The installation instructions only setup a test environment.

Any feedback is very much appreciated, thank you!

## Installation instructions for Ubuntu 12.04.2 LTS (Precise Pangolin)

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
    git clone git://github.com/joelonsql/pci-blackbox.git
    # echo "INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password, PCIBlackBoxURL) \
    # VALUES ('Adyen', 'TrustlyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompany', 'yourpassword', 'https://localhost:30002/pci');"\
    # > ./pci-blackbox/nonpci/populate.sql

### 5. Install pci-blackbox
    cd pci-blackbox
    export MY_EXTERNAL_IP=`ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
    sudo perl -s -i -p -e "s/MY_EXTERNAL_IP/$MY_EXTERNAL_IP/g" ./nonpci/FUNCTIONS/authorise.sql
    sudo -u postgres psql -f install.sql
    sudo sh -c 'cat pg_service.conf >> /etc/postgresql-common/pg_service.conf'
    perl Makefile.PL && make && sudo make install
    sudo cp sites-available/pci-ssl /etc/apache2/sites-available/pci-ssl
    sudo cp sites-available/nonpci-ssl /etc/apache2/sites-available/nonpci-ssl
    sudo perl -s -i -p -e "s/MY_EXTERNAL_IP/$MY_EXTERNAL_IP/g" /etc/apache2/sites-available/*
    sudo sh -c 'cat ports.conf >> /etc/apache2/ports.conf'
    sudo sh -c 'echo ServerName localhost >> /etc/apache2/httpd.conf'
    sudo a2enmod perl ssl
    sudo a2ensite pci-ssl nonpci-ssl
    sudo cp -r nonpci/www_document_root /var/www/nonpci
    sudo cp -r pci/www_document_root /var/www/pci
    sudo perl -s -i -p -e "s/MY_EXTERNAL_IP/$MY_EXTERNAL_IP/g" /var/www/nonpci/index.html
    sudo service apache2 reload
    sudo -u www-data prove



