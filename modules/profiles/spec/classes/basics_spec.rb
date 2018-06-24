require 'spec_helper'

describe 'profiles::basics' do

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
        it { is_expected.to contain_ferm__rule('allow_ssh') }
        it { is_expected.to contain_class('ferm') }
        it { is_expected.to contain_package('unzip') }
        it { is_expected.to contain_yumrepo('epel') }
        it { is_expected.to contain_class('ssh') }
      end
    end
  end
end
