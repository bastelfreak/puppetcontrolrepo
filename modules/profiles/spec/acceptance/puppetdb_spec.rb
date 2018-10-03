$module_dependencies = ['puppetdb']
require 'spec_helper_acceptance'

describe 'profiles::puppetdb class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      include profiles::puppetdb
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
  describe package('puppetdb') do
    it { is_expected.to be_installed }
  end
  describe service('puppetdb') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end
