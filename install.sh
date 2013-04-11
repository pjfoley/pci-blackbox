#!/bin/sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install cpanminus build-essential postgresql-9.1 \
postgresql-contrib-9.1 postgresql-plperl-9.1 libplack-perl libdbd-pg-perl \
libjson-perl libmodule-install-perl libtest-exception-perl \
libapache2-mod-perl2 apache2-mpm-prefork git-core libtest-deep-perl \
libfile-slurp-perl libwww-curl-perl git libdbix-connector-perl
cpanm --sudo DBIx::Pg::CallFunction JSON::RPC::Simple::Client
git clone git://github.com/joelonsql/pci-blackbox.git
# echo "INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password, PCIBlackBoxURL) \
# VALUES ('Adyen', 'TrustlyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompany', 'yourpassword', 'https://localhost:30002/pci');"\
# > ./pci-blackbox/nonpci/populate.sql
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
