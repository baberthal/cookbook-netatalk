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

# require 'spec_helper'

RSpec.shared_examples 'the source recipe' do |platform, version|
  deps = if platform == 'centos'
           %w(rpm-build gcc make avahi-devel bison cracklib-devel dbus-devel
              dbus-glib-devel docbook-style-xsl flex libacl-devel libattr-devel
              libdb-devel libevent-devel libgcrypt-devel libxslt krb5-devel
              dconf mariadb-devel openldap-devel openssl-devel pam-devel
              quota-devel systemtap-sdt-devel tcp_wrappers-devel libtdb-devel
              tracker-devel)
         else
           v = version == '14.04' ? '0.16' : '1.0'
           %W(build-essential libevent-dev libssl-dev libgcrypt11-dev
              libkrb5-dev libpam0g-dev libwrap0-dev libdb-dev libtdb-dev
              libmysqlclient-dev libavahi-client-dev libacl1-dev libldap2-dev
              libcrack2-dev systemtap-sdt-dev libdbus-1-dev libdbus-glib-1-dev
              libglib2.0-dev tracker libtracker-sparql-#{v}-dev avahi-daemon
              libtracker-miner-#{v}-dev)
         end

  describe 'installs the dependencies' do
    deps.each do |dep|
      it "installs #{dep}" do
        expect(chef_run).to install_package dep
      end
    end
  end

  it 'downloads the remote file' do
    expect(chef_run).to create_remote_file(
      '/var/chef/cache/netatalk-3.1.7.tar.bz2')
  end

  it 'runs the install script' do
    expect(chef_run).to run_bash('install_netatalk').with(
      cwd: '/var/chef/cache'
    )
  end
end

RSpec.describe 'netatalk::source' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }
  supported_platforms = {
    'ubuntu' => %w(14.04 15.04 15.10),
    'centos' => %w(7.0 7.1.1503),
    'debian' => %w(7.8 8.0 8.1)
  }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform} v#{version}" do
        let(:opts) { { platform: platform, version: version } }
        include_examples 'converges successfully'
        it_behaves_like 'the source recipe', platform, version
      end
    end
  end
end
