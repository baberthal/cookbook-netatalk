#
# Cookbook Name:: netatalk
# Spec:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2015 J. Morgan Lieberthal
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

RSpec.describe 'netatalk::rpm_src' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }

  %w(7.0 7.1.1503).each do |version|
    context "on centos v#{version}" do
      let(:opts) { { platform: 'centos', version: version } }
      include_examples 'converges successfully'
      dep = %w(rpm-build gcc make avahi-devel bison cracklib-devel dbus-devel
               dbus-glib-devel docbook-style-xsl flex libacl-devel
               libattr-devel libdb-devel libevent-devel libgcrypt-devel libxslt
               krb5-devel dconf mariadb-devel openldap-devel openssl-devel
               pam-devel quota-devel systemtap-sdt-devel tcp_wrappers-devel
               libtdb-devel tracker-devel)
      describe 'installing the dependencies' do
        it 'installs the dependencies' do
          expect(chef_run).to install_package dep
        end
      end

      it 'downloads the remote rpm source' do
        expect(chef_run).to create_remote_file(
          '/var/chef/cache/netatalk-3.1.7-1.2.fc24.src.rpm')
      end

      it 'installs the source rpm' do
        expect(chef_run).to install_rpm_package('netatalk').with(
          source: '/var/chef/cache/netatalk-3.1.7-1.2.fc24.src.rpm')
      end

      describe 'building the rpm source' do
        let(:built_rpms) do
          %w(/root/rpmbuild/RPMS/x86_64/one.rpm
             /root/rpmbuild/RPMS/x86_64/two.rpm
             /root/rpmbuild/RPMS/x86_64/three.rpm)
        end
        let(:rpm_source) { chef_run.rpm_package('netatalk') }
        let(:build_script) { chef_run.bash('build_rpm') }
        before do
          allow(Dir).to receive(:[]).and_call_original
          allow(Dir).to receive(:[]).with('/root/rpmbuild/RPMS/**/*.rpm')
            .and_return(built_rpms)
        end

        it 'the bash script does nothing by default' do
          expect(build_script).to do_nothing
        end

        it 'the bash script notifies the ruby block to reload attrs' do
          expect(build_script).to notify('ruby_block[find_built_rpms]')
            .to(:run).immediately
        end

        it 'runs the ruby block to reload packages' do
          expect(chef_run).to run_ruby_block('find_built_rpms')
        end

        it 'notifies the bash script to run' do
          expect(rpm_source).to notify('bash[build_rpm]').to(:run).immediately
        end

        it 'installs the packages the we just built' do
          %w(netatalk-one netatalk-two netatalk-three).each do |pkg_name|
            package = chef_run.rpm_package(pkg_name)
            expect(package).to do_nothing
            expect(package).to subscribe_to('ruby_block[find_built_rpms]')
          end
        end
      end
    end
  end
end
