require 'spec_helper'

describe 'profiles::foreman' do

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
        it { is_expected.to contain_foreman__plugin('column_view') }
        it { is_expected.to contain_package('rubygem-foreman_maintain-doc') }
        it { is_expected.to contain_package('rubygem-foreman_maintain') }
        it { is_expected.to contain_class('profiles::firewall_http') }
        it { is_expected.to contain_class('profiles::firewall_https') }
        it { is_expected.to contain_class('foreman') }
        it { is_expected.to contain_class('foreman::plugin::tasks') }
        it { is_expected.to contain_class('ferm') }
        it { is_expected.to contain_class('memcached') }
        it { is_expected.to contain_class('foreman::plugin::memcache') }
        it { is_expected.to contain_class('foreman::plugin::puppetdb') }
        it { is_expected.to contain_class('foreman::plugin::default_hostgroup') }
        it { is_expected.to contain_class('foreman::plugin::hooks') }
      end
    end
  end
end
