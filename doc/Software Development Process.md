# Software Development Process

Even though the source code has been made open source and licensed under the MIT-license,
the development of the pci-blackbox is the responsibility of Trustly Group AB and its IT-department.

Trustly Group AB adheres to the secure coding guidelines outlined by the [Open Web Security Project Guide](https://www.owasp.org/index.php/Main_Page).

Code reviews are performed by a different developer than the author of a code change.
Before any code is commited, a sign-off is required from at least one other developer.

The pci-blackbox uses a versioning system where the first digits incidate the major version, and the second digits indicate the minor version.
Upgrades of minor versions can be made without restarting the server and doesn't require any special instructions.
Upgrades of major versions typically require schema modifications and must be carried out carefully within scheduled maintenance windows.

The lead developer of the pci-blackbox is Joel Jacobson <joel@trustly.com>.
Lukas Gratte <lukas@trustly.com> is responsible for the front-end code of the pci-blackbox.

The pci-blackbox is only certified to be installed on a server running the Linux operating system Ubuntu 12.04.2 LTS (Precise Pangolin).

Automatic security updates must be enabled.

Before deploying, the Ubuntu server must be upgraded with all the latest packages using the commands:

    sudo apt-get update
    sudo apt-get upgrade

Before deploying the pci-blackbox, the system must be tested in a test environment, physically separate from the production environment.

To run all the tests, execute the following command:

    cd pci-blackbox
    sudo -u www-data prove

Should any test _FAIL_, you must _not_ deploy the pci-blackbox in production. Contact the Software Vendor to resolve the issue.

The personnel responsible for testing the pci-blackbox _must not_ be the same as the personnel responsible for deploying the pci-blackbox in production.

When testing the pci-blackbox, no live PANs (card number) are being used in the unit tests. _DO NOT_ enter real card numbers in the unit tests.

After completing the tests in the production environment, drop the database and install everything from scratch to ensure no test data persists after the system becomes active.
This is achieved by the following commands:

    cd pci-blackbox
    sudo -u postgres dropdb pci
    sudo -u postgres createdb pci
    sudo -u postgres psql -f install.sql



