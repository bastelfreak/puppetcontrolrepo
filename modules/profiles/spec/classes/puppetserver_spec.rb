require 'spec_helper'

describe 'profiles::puppetserver' do

  let :node do
    'puppet.local'
  end

  on_supported_os.each do |os, facts|
    next if facts[:os]['family'] == 'Archlinux'
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ferm') }
        it { is_expected.to contain_class('puppet') }
        it { is_expected.to contain_class('nginx') }
        it { is_expected.to contain_class('r10k') }
        it { is_expected.to contain_class('prometheus::graphite_exporter') }
        it { is_expected.to contain_ferm__rule('allow_puppet') }
        it { is_expected.to contain_nginx__resource__server('127.0.0.1') }
        it { is_expected.to nginx__resource__location('nginx_status') }
      end
    end
  end
end
