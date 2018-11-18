$module_dependencies = ['choria', 'ferm', 'augeasproviders_sysctl']
require 'spec_helper_acceptance'

describe 'profiles::choriaclient class' do
  shell('puppet cert generate puppet.local --dns_alt_names=puppet.local,puppet,puppetdb,puppetdb.local')
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      if fact('os.name') == 'CentOS'
        apply_manifest('package{"epel-release": ensure => present}', catch_failures: true)
      end

      pp = <<-EOS
      include profiles::choriaclient
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
