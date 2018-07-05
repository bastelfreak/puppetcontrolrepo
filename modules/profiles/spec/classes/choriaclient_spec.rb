require 'spec_helper'

describe 'profiles::choriaclient' do

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
        it { is_expected.to contain_sysctl('net.core.somaxconn') }
        it { is_expected.to contain_sysctl('net.ipv4.tcp_max_syn_backlog') }
        it { is_expected.to contain_class('choria::broker') }
        it { is_expected.to contain_service('choria-broker') }
      end
    end
  end
end
