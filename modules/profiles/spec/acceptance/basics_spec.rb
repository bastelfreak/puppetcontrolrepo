$module_dependencies = ['ferm', 'ssh']
require 'spec_helper_acceptance'

describe 'profiles::basics class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      include profiles::basics
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    # centos7
    describe package('openssh-server') do
      it { is_expected.to be_installed }
    end
    describe service('sshd') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
end
