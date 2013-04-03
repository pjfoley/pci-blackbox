#!/bin/sh
if [ -e nonpci/populate.sql ]
    then
        psql -f install.sql
        prove
    else
        echo "!!!! IMPORTANT !!!"
        echo
        echo "You need a test merchant account with any of the PSPs supported to use this system."
        echo "Then create the file nonpci/populate.sql with your credentials,"
        echo "Example nonpci/populate.sql file:"
        echo "INSERT INTO MerchantAccounts (PSP, MerchantAccount, URL, Username, Password) VALUES ('Adyen', 'YourCompanyCOM', 'https://pal-test.adyen.com/pal/servlet/soap/Payment', 'ws@Company.YourCompanyInc', 's3cr3tp4ssw0rd');"
fi
