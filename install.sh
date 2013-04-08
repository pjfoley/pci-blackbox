#!/bin/sh
if [ -e nonpci/populate.sql ]
    then
        if [ ! -f /private/etc/apache2/pciblackbox_pci.key ]
            then
                sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /private/etc/apache2/pciblackbox_pci.key -out /private/etc/apache2/pciblackbox_pci.crt
                sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /private/etc/apache2/pciblackbox_nonpci.key -out /private/etc/apache2/pciblackbox_nonpci.crt
        fi
        sudo -u postgres psql -f install.sql
        sudo -u www-data prove
    else
        echo "!!!! IMPORTANT !!!"
        echo
        echo "You need a test merchant account with any of the PSPs supported to use this system."
        echo "Then create the file nonpci/populate.sql with your credentials,"
        echo "Example nonpci/populate.sql file:"
        echo "INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password) VALUES ('Adyen', 'YourCompanyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompanyInc', 's3cr3tp4ssw0rd');"
fi
