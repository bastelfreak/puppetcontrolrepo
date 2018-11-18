$module_dependencies = ['prometheus', 'nginx']
require 'spec_helper_acceptance'

describe 'profiles::node_exporter class' do
  shell('puppet cert generate puppet.local --dns_alt_names=puppet.local,puppet,puppetdb,puppetdb.local')
  install_module_from_forge('puppetlabs-apt', '>= 6.1.1 < 7.0.0') if fact('os.family') == 'Debian'
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      include profiles::node_exporter
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe package('nginx') do
      it { is_expected.to be_installed }
    end
    describe service('nginx') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe service('node_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
end
