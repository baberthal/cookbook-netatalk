#
# Cookbook Name:: netatalk
# Recipe:: deb_build
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

apt_package node['netatalk']['deb_build']['dependencies']
apt_package 'avahi-daemon'

group node['netatalk']['deb_build']['user']['group']

user node['netatalk']['deb_build']['user']['username'] do
  comment 'A user to build packages'
  home node['netatalk']['deb_build']['user']['home']
  manage_home true
  group node['netatalk']['deb_build']['user']['group']
  shell '/bin/bash'
end

group 'sudo' do
  append true
  members node['netatalk']['deb_build']['user']['username']
  action :modify
end

git 'netatalk-debian' do
  repository node['netatalk']['deb_build']['source']
  action :sync
  destination "#{node['netatalk']['deb_build']['user']['home']}/netatalk-debian"
  user node['netatalk']['deb_build']['user']['username']
end

build_dir = node['netatalk']['deb_build']['user']['home']

bash 'build_debs' do
  cwd "#{build_dir}/netatalk-debian"
  code 'debuild -b -uc -us'
  action :run
  creates "#{build_dir}/netatalk_3.1.7-1_amd64.deb"
end

ruby_block 'reload_built_debs' do
  block do
    node.default['netatalk']['deb_build']['built'] = Dir["#{build_dir}/*.deb"]
    ns = node['netatalk']['deb_build']['built'].map { |d| ::File.basename(d) }
    libatalk = run_context.resource_collection.find(dpkg_package: 'libatalk')
    libatalkd = run_context.resource_collection.find(dpkg_package: 'libatalk-d')
    netatalk = run_context.resource_collection.find(dpkg_package: 'netatalkdeb')

    libatalk.source node['netatalk']['deb_build']['built'][1]
    libatalk.package_name ns[1]
    libatalkd.source node['netatalk']['deb_build']['built'][0]
    libatalkd.package_name ns[0]
    netatalk.source node['netatalk']['deb_build']['built'][2]
    netatalk.package_name ns[2]
  end
end

dpkg_package 'libatalk' do
  source nil
  package_name nil
  action :install
  subscribes :install, 'ruby_block[reload_built_debs]', :immediately
end

dpkg_package 'libatalk-d' do
  source nil
  package_name nil
  action :install
  subscribes :install, 'dpkg_package[libatalk]', :immediately
end

dpkg_package 'netatalkdeb' do
  source nil
  package_name nil
  action :install
  subscribes :install, 'ruby_block[reload_built_debs]', :immediately
end
