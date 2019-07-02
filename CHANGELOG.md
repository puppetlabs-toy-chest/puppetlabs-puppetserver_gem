# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.1]
### Summary
Minor changes to gem documentation params.

### Fixed
- (FM-7681) puppetserver_gem - match gem documentation params


## [1.1.0]
### Summary
This release includes minor documentation updates, a compatibility update which means this module is now compatible with Puppet versions less than 7.0.0 and finally a feature to accelerate the puppetserver_gem list.

### Fixed
- ensure that the HOME component of the environment is passed through to the puppetserver script to enable access to proxy server settings that are usually in `/root/.gemr`

### Added
- (FM-7145) accelerate puppetserver_gem list

## [1.0.0]
### Summary
This is the first officially stable release of puppetserver\_gem. This is a
bugfix release and no backwards-incompatible changes have been made.

### Fixed
- MODULES-4815 Make `install_options` come before `source` to allow flags such
  as `--clear-sources` to work.

## [0.2.0]
### Features:
This adds the ability to use install & uninstall options as in the parent provider.

## 0.1.0 - 2015-05-28
### Summary:
This module provides management of Ruby gems on puppet. This is the initial release
of the puppetserver_gem it supersedes the module pe_puppetserver_gem. This module
will support both FOSS and PE. With Puppet 4 the path to the puppetserver binary has
changed.

### Notes:
To test manually against the default nodeset. Run the acceptance test as normal.
curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb ; dpkg -i puppetlabs-release-pc1-trusty.deb
apt-get update
apt-get install puppetserver
optional, make sure that the puppetserver_gem is in the correct place
  cp -r /etc/puppet/modules/puppetserver_gem /etc/puppetlabs/code/environments/production/modules/
/opt/puppetlabs/bin/puppet apply apply_manifest.pp.****  

[1.1.0]: https://github.com/puppetlabs/puppetlabs-puppetserver_gem/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/puppetlabs/puppetlabs-puppetserver_gem/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/puppetlabs/puppetlabs-puppetserver_gem/compare/0.2.0...1.0.0
[0.2.0]: https://github.com/puppetlabs/puppetlabs-puppetserver_gem/compare/0.1.0...0.2.0
