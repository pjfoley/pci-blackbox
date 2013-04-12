#!/bin/sh
sudo -u postgres dropdb pci
sudo -u postgres dropdb nonpci
export MY_EXTERNAL_IP=`ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
sudo perl -s -i -p -e "s/MY_EXTERNAL_IP/$MY_EXTERNAL_IP/g" ./nonpci/FUNCTIONS/authorise.sql
sudo -u postgres psql -f install.sql
perl Makefile.PL && make && sudo make install
sudo cp sites-available/pci-ssl /etc/apache2/sites-available/pci-ssl
sudo cp sites-available/nonpci-ssl /etc/apache2/sites-available/nonpci-ssl
sudo perl -s -i -p -e "s/MY_EXTERNAL_IP/$MY_EXTERNAL_IP/g" /etc/apache2/sites-available/*
sudo rm -rf /var/www/nonpci
sudo rm -rf /var/www/pci
sudo cp -r nonpci/www_document_root /var/www/nonpci
sudo cp -r pci/www_document_root /var/www/pci
sudo perl -s -i -p -e "s/MY_EXTERNAL_IP/$MY_EXTERNAL_IP/g" /var/www/nonpci/index.html
sudo service apache2 restart
