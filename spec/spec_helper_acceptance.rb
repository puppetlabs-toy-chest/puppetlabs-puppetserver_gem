require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker-task_helper'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

if ENV['BEAKER_provision'] != 'no'
  run_puppet_install_helper
  install_module_on(hosts)
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation
  c.before :suite do
    unless ENV['BEAKER_TESTMODE'] == 'local'
      unless ENV['BEAKER_provision'] == 'no'
        # intentionally blank
      end
      hosts.each do |host|
        # intentionally blank
      end
    end
  end
end
