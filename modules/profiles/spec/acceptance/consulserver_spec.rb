$module_dependencies = ['consul']
require 'spec_helper_acceptance'

describe 'profiles::consulserver class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      include profiles::consulserver
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)

    end
    describe service('consul') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
end
