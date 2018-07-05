require 'spec_helper'

describe 'profiles::firewall_http' do

  let :node do
    'puppet.local'
  end

  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_ferm__rule('allow_http') }
      end
    end
  end
end
