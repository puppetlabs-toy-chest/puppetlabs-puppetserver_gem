# puppetserver_gem module

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with puppetserver_gem](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module description

This module provides management of Ruby gems for both PE and FOSS Puppet Server. It supercedes the deprecated pe_puppetserver_gem.
This uses gem as a parent and uses `puppetserver gem` command for all gem operations.

## Setup

To install a gem from RubyGems into Puppet Server:
```puppet
    package { 'json':
      ensure   => present,
      provider => puppetserver_gem,
    }
```
## Usage

### To add the 'json' gem from the default gem sources:
By default there is one gem source which is https://rubygems.org
```puppet
    package { 'json':
      ensure   => present,
      provider => puppetserver_gem,
    }
```
### To uninstall the 'json' gem:
```puppet
    package { 'json':
      ensure   => absent,
      provider => puppetserver_gem,
    }
```
This is equivalent to the command line: `puppetserver gem install --no-rdoc --no-ri json`

### To add a specifc version of a gem from a specific gem repository without first checking the default gem sources:
```puppet
    package { 'mygem':
      ensure          => '1.2',
      install_options => ['--clear-sources', '--no-document'],
      provider        => puppetserver_gem,
      source          => "https://some-gem-repo.org",
    }
```
This is equivalent to the command line: `puppetserver gem install -v 1.2 --clear-sources --no-document --source https://some-gem-repo.org mygem`

## Reference

### Proxy support
Proxy servers are supported via through the `.gemrc` file which is normally
present at `/root/.gemrc`:

```
http_proxy: http://proxy.megacorp.com:8888
https_proxy: http://proxy.megacorp.com:8888
```

## Limitations

This module has been tested on PE and FOSS, and no issues have been identified. It is a wrapper around the `puppetserver gem` command line, and so has the same limitations around [Gems with native (C) extensions](https://docs.puppet.com/puppetserver/latest/gems.html#gems-with-native-c-extensions)

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

## Testing

At the minute, there is only an acceptance test for FOSS Puppet Server.
