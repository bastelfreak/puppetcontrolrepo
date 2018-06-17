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
        it { is_expected.to contain_ferm__rule('allow_puppet') }
      end
    end
  end
end
