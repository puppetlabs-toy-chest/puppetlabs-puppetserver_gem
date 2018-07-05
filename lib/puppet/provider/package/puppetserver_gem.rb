require 'facter'
require 'rubygems/commands/list_command'
require 'puppet/provider/package'
require 'stringio'
require 'uri'

# Ruby gems support.
Puppet::Type.type(:package).provide :puppetserver_gem, :parent => :gem do
  desc "Puppet Server Ruby Gem support. If a URL is passed via `source`, then
    that URL is appended to the list of remote gem repositories which by default
    contains rubygems.org; To ensure that only the specified source is used also
    pass `--clear-sources` in via `install_options`; if a source is present but is
    not a valid URL, it will be interpreted as the path to a local gem file.  If
    source is not present at all, the gem will be installed from the default gem
    repositories."

  has_feature :versionable, :install_options, :uninstall_options

  confine :feature => :hocon
  commands :puppetservercmd => '/opt/puppetlabs/bin/puppetserver'

  # The HOME variable is lost to the puppetserver script
  #  and needs to be injected directly into the call to `execute()`
  # When doing so, restore :failonfail and :combine to their defaults
  #  as per the documentation in lib/puppet/util/execution.rb
  EXEC_OPTS = { :failonfail => true, :combine => true, :custom_environment => { :HOME => ENV['HOME'] } }

  def self.gemlist(options)
    gem_list_command = [command(:puppetservercmd), 'gem', 'list']

    if options[:local]
      gem_list_command << '--local'
    else
      gem_list_command << '--remote'
    end

    if options[:source]
      gem_list_command << "--source #{options[:source]}"
    end

    if name = options[:justme]
      gem_regex = '\A' + name + '\z'
      gem_list_command << gem_regex
    end

    if options[:local]
      list = execute_rubygems_list_command(gem_regex)
    else
      begin
        list = execute(gem_list_command, EXEC_OPTS)
      rescue Puppet::ExecutionFailure => detail
        raise Puppet::Error, _("Could not list gems: %{detail}") % { detail: detail }, detail.backtrace
      end
    end

    # When `/tmp` is mounted `noexec`, `puppetserver gem list` will output *** LOCAL GEMS ***
    #  causing gemsplit to output: Warning: Could not match *** LOCAL GEMS ***
    gem_list = list
               .lines
               .select { |x| x =~ /^(\S+)\s+\((.+)\)/ }
               .map { |set| gemsplit(set) }

    if options[:justme]
      return gem_list.shift
    else
      return gem_list
    end
  end

  # The puppetserver gem cli commands are particularly slow as they start a JVM.
  # Instead, for the often-executed list command, use the rubygems library from the puppet ruby,
  #  setting the GEM_HOME and GEM_PATH to the values in the puppetserver configuration file.
  # The rubygems library does not have access to java platform gems, for example: json (1.8.3 java),
  #  but java platform gems should not be managed, by design.

  def self.execute_rubygems_list_command(gem_regex)
    pe_puppetserver_conf_file = '/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf'
    os_puppetserver_conf_file = '/etc/puppetlabs/puppetserver/puppetserver.conf'
    puppetserver_gem_home = '/opt/puppetlabs/server/data/puppetserver/jruby-gems'
    puppetserver_gem_path = [puppetserver_gem_home, '/opt/puppetlabs/server/data/puppetserver/vendored-jruby-gems']
    puppetserver_conf_file = Facter.value(:pe_server_version) ? pe_puppetserver_conf_file : os_puppetserver_conf_file
    puppetserver_conf = Hocon.load(puppetserver_conf_file)
    gem_env = {}
    if puppetserver_conf.empty?
      gem_env['GEM_HOME'] = puppetserver_gem_home
      gem_env['GEM_PATH'] = puppetserver_gem_path.join(':')
    else
      gem_env['GEM_HOME'] = puppetserver_conf['jruby-puppet']['gem-home']
      gem_env['GEM_PATH'] = puppetserver_conf['jruby-puppet']['gem-path'].join(':')
    end
    gem_env['GEM_SPEC_CACHE'] = "/tmp/#{$$}"
    Gem.paths = gem_env

    sio_inn = StringIO.new
    sio_out = StringIO.new
    sio_err = StringIO.new
    stream_ui = Gem::StreamUI.new(sio_inn, sio_out, sio_err, false)
    gem_list_cmd = Gem::Commands::ListCommand.new
    gem_list_cmd.options[:domain] = :local
    gem_list_cmd.options[:args] = [gem_regex] if gem_regex
    gem_list_cmd.ui = stream_ui
    gem_list_cmd.execute

    # Remove default gems from the list, as the are the default gems from the puppet ruby:
    #  /opt/puppetlabs/puppet/lib/ruby/gems/x.y.z/specifications/default
    # There is no method exclude default gems from the local gem list, for example: psych (default: 2.2.2),
    #  but default gems should not be managed, by design.
    gem_list = sio_out.string.lines.reject { |gem| gem =~ / \(default\: / }
    gem_list.join("\n")
  ensure
    Gem.clear_paths
  end

  def install(useversion = true)
    command = [command(:puppetservercmd), 'gem', 'install']
    command += install_options if resource[:install_options]
    command << '-v' << resource[:ensure] if (! resource[:ensure].is_a? Symbol) and useversion

    if source = resource[:source]
      begin
        uri = URI.parse(source)
      rescue => detail
        self.fail Puppet::Error, _("Invalid source '%{uri}': %{detail}") % { uri: uri, detail: detail }, detail
      end

      case uri.scheme
        when nil
          # no URI scheme => interpret the source as a local file
          command << source
        when /file/i
          command << uri.path
        when 'puppet'
          # we don't support puppet:// URLs (yet)
          raise Puppet::Error.new(_("puppet:// URLs are not supported as gem sources"))
        else
          # interpret it as a gem repository
          command << '--source' << "#{source}" << resource[:name]
      end
    else
      command << '--no-rdoc' << '--no-ri' << resource[:name]
    end

    output = execute(command, EXEC_OPTS)
    # Apparently, some gem versions don't exit non-0 on failure.
    self.fail _("Could not install: %{output}") % { output: output.chomp } if output.include?('ERROR')
  end

  def uninstall
    command = [command(:puppetservercmd), 'gem', 'uninstall']
    command << '--executables' << '--all' << resource[:name]
    command << uninstall_options if resource[:uninstall_options]

    output = execute(command, EXEC_OPTS)
    # Apparently, some gem versions don't exit non-0 on failure.
    self.fail _("Could not uninstall: %{output}") % { output: output.chomp } if output.include?('ERROR')
  end
end
