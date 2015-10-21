require 'spec_helper'

RSpec.describe 'netatalk::default' do
  describe command('afpd -V') do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match(/afpd has been compiled/) }
    its(:stdout) { is_expected.to match(/^afpd 3\.[0-9]\.[0-9]/) }
  end

  case os[:family]
  when 'redhat'
    describe file('/etc/netatalk/afp.conf') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
    end
  when 'debian'
    describe file('/etc/netatalk/afp.conf'), if: os[:release].to_f >= 8.0 do
      it { is_expected.to exist }
      it { is_expected.to be_file }
    end
  when 'ubuntu'
    describe file('/usr/local/etc/afp.conf') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
    end
  end

  describe service('avahi-daemon') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('netatalk') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end
