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

RSpec.describe 'netatalk::jessie' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }
  %w(8.0 8.1).each do |version|
    context "on debian v#{version}" do
      let(:opts) { { platform: 'debian', version: version } }
      include_examples 'converges successfully'
      let(:dependencies) do
        %w(libcrack2
           libmysqlclient18
           libavahi-client3
           libdbus-glib-1-2
           avahi-daemon)
      end

      it 'creates the directory for package downloads' do
        expect(chef_run).to create_directory('/var/chef/cache/netatalk')
      end

      it 'installs the dependencies' do
        expect(chef_run).to install_package dependencies
      end

      packages = %w(libatalk-dev_3.1.7-1_amd64.deb
                    libatalk16_3.1.7-1_amd64.deb
                    netatalk_3.1.7-1_amd64.deb)

      packages.each do |pkg|
        it "downloads the remote file for #{pkg}" do
          expect(chef_run).to create_remote_file(
            "/var/chef/cache/netatalk/#{pkg}")
        end

        it "installs the package #{pkg}" do
          expect(chef_run).to install_dpkg_package(pkg)
        end
      end
    end
  end
end
