require 'spec_helper_acceptance'

describe 'puppetserver_gem' do
  let(:test_gem) { 'world_airports' }

  context 'installing a gem with the puppetserver_gem provider' do
    it 'should execute without error' do
      filename = '/tmp/puppetserver_gem_install.pp'
      pp = <<-EOS
        package { '#{test_gem}':
          ensure   => present,
          provider => puppetserver_gem,
        }
      EOS
      create_remote_file(master, filename, pp)
      on(master, puppet('apply', filename), acceptable_exit_codes: 0)
    end
    it 'should successfully install the gem' do
      on(master, "puppetserver gem list | grep #{test_gem}", acceptable_exit_codes: 0)
    end
  end

  context 'listing gems with the puppetserver_gem provider' do
    it 'should list the gem' do
      result = on(master, puppet('resource', 'package', '--param provider', test_gem), acceptable_exit_codes: 0).stdout
      expect(result).to match(/puppetserver_gem/)
    end
  end

  context 'removing a gem with the puppetserver_gem provider' do
    it 'should execute without error' do
      filename = '/tmp/puppetserver_gem_uninstall.pp'
      pp = <<-EOS
        package { '#{test_gem}':
          ensure   => absent,
          provider => puppetserver_gem,
        }
      EOS
      create_remote_file(master, filename, pp)
      on(master, puppet('apply', filename), acceptable_exit_codes: 0)
    end
    it 'should successfully remove the gem' do
      on(master, "puppetserver gem list | grep #{test_gem}", acceptable_exit_codes: 1)
    end
  end
end
