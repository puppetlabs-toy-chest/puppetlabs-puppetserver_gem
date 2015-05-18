# puppetlabs puppetserver_gem module

This module provides management of Ruby gems for both PE and FOSS Puppet Server.


For PE Puppet Server:

    package { 'json':
      ensure   => present,
      provider => puppetserver_gem,
    }

This uses gem as a parent and uses `puppetserver gem` command for all gem operations.
