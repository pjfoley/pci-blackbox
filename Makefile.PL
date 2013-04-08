use inc::Module::Install;

name            'PCIBlackBox';
author          'Joel Jacobson';
version         '0.01';
abstract        'PCI-DSS compliant card payment module';

license         'MIT';
requires        'DBI'               => '1.605';
requires        'DBD::Pg'           => 0;
requires        'DBIx::Connector'   => 0;
requires        'Carp'              => 0;
requires        'JSON'              => 0;
requires        'Plack::Request'    => 0;

test_requires   'Test::More'     => 0;

install_script  'scripts/pci-blackbox.psgi';

WriteAll;
