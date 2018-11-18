# the following modules are explicit dependencies, but also a dependency of the choria/choria module
# so we don't need to specify them in $module_dependencies
# mcollective_agent_service
# mcollective_agent_package
# mcollective_agent_filemgr
# mcollective_agent_puppet
$module_dependencies = ['choria', 'mcollective_agent_puppetca', 'mcollective_agent_bolt_tasks', 'mcollective_agent_shell', 'mcollective_agent_process', 'mcollective_agent_iptables', 'mcollective_agent_nrpe', 'mcollective_agent_nettest', 'mcollective_data_sysctl']
require 'spec_helper_acceptance'

describe 'profiles::choriaserver class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      # cron is required, but missing in the Ubuntu docker images
      if fact('os.name') == 'Ubuntu'
        apply_manifest('package{"cron": ensure => present}', catch_failures: true)
      end
      pp = <<-EOS
      include profiles::choriaserver
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
