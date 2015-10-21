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

RSpec.describe 'netatalk::deb_build' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }
  supported_platforms = {
    'ubuntu' => %w(14.04 15.04 15.10),
    'debian' => %w(7.8 8.0 8.1)
  }

  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform} v#{version}" do
        let(:opts) { { platform: platform, version: version } }
        include_examples 'converges successfully'
        it 'installs the dependencies' do
          expect(chef_run).to install_apt_package %w(build-essential
                                                     devscripts
                                                     debhelper
                                                     cdbs
                                                     autotools-dev
                                                     git
                                                     dh-buildinfo
                                                     libdb-dev
                                                     libwrap0-dev
                                                     libpam0g-dev
                                                     libcups2-dev
                                                     libkrb5-dev
                                                     libltdl3-dev
                                                     libgcrypt11-dev
                                                     libcrack2-dev
                                                     libavahi-client-dev
                                                     libldap2-dev
                                                     libacl1-dev
                                                     libevent-dev
                                                     d-shlibs
                                                     dh-systemd)
        end

        it 'creates the build user' do
          expect(chef_run).to create_user('builder').with(
            home: '/home/builder',
            group: 'builder'
          )
        end

        it 'adds the builder to the sudo group' do
          expect(chef_run).to modify_group('sudo').with(
            append: true,
            members: %w(builder)
          )
        end

        it 'clones the git repository' do
          expect(chef_run).to sync_git('netatalk-debian').with(
            repository: 'https://github.com/adiknoth/netatalk-debian.git',
            destination: '/home/builder/netatalk-debian',
            user: 'builder'
          )
        end
      end
    end
  end
end
