require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)

# install only needed dependencies. Variable needs to be defined within each spec file
if $module_dependencies
  require 'json'
  metadata = JSON.parse(File.read('metadata.json'))
  dependencies = metadata['dependencies']
  filtered_dependencies = dependencies.select{|dependency| $module_dependencies.include?(dependency['name'].split('/')[1])}
  filtered_dependencies.each do |dependency|
    install_module_from_forge(dependency['name'], dependency['version_requirement'])
  end
else
  install_module_dependencies_on(hosts)
end
RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  hosts.each do |host|
    if host[:platform] =~ %r{el-7-x86_64} && host[:hypervisor] =~ %r{docker}
      on(host, "sed -i '/nodocs/d' /etc/yum.conf")
    end

    # setup hiera data
    write_hiera_config_on(host, ['%<::osfamily>s'])
    copy_hiera_data_to(host, './spec/acceptance/hieradata/')
  end
end
