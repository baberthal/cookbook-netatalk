#
# Cookbook Name:: netatalk
# Recipe:: rpm_src
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

cache_path = Chef::Config[:file_cache_path]
filename = node['netatalk']['rpm_source']['url'].split('/').last

package node['netatalk']['source']['dependencies'] do
  action :install
end

remote_file "#{cache_path}/#{filename}" do
  source node['netatalk']['rpm_source']['url']
  checksum node['netatalk']['rpm_source']['checksum']
end

rpm_package 'netatalk' do
  source "#{cache_path}/#{filename}"
  notifies :run, 'bash[build_rpm]', :immediately
  not_if { ::File.exist?('/root/rpmbuild/SPECS/netatalk.spec') }
end

bash 'build_rpm' do
  action :nothing
  cwd '/root/rpmbuild/SPECS'
  code 'rpmbuild -bb netatalk.spec'
end

ruby_block 'find_built_rpms' do
  block do
    node.default['netatalk']['built_rpms'] = Dir['/root/rpmbuild/RPMS/**/*.rpm']
    basenames = node['netatalk']['built_rpms'].map { |f| ::File.basename(f) }
    one = run_context.resource_collection.find(rpm_package: 'netatalk-one')
    two = run_context.resource_collection.find(rpm_package: 'netatalk-two')
    three = run_context.resource_collection.find(rpm_package: 'netatalk-three')
    one.source node['netatalk']['built_rpms'][0]
    one.package_name basenames[0]

    two.source node['netatalk']['built_rpms'][1]
    two.package_name basenames[1]

    three.source node['netatalk']['built_rpms'][2]
    three.package_name basenames[2]
  end
  subscribes :run, 'bash[build_rpm]', :immediately
  notifies :install, 'rpm_package[netatalk-one]', :immediately
  notifies :install, 'rpm_package[netatalk-two]', :immediately
  notifies :install, 'rpm_package[netatalk-three]', :immediately
end
# node['netatalk']['built_rpms'].each do |rpm_file|
#   rpm_package rpm_file do
#     subscribes :install, 'bash[build_rpm]', :immediately
#     source "/root/rpmbuild/RPMS/#{node['arch']}/#{rpm_file}"
#     options '-Uvh'
#     only_if { ::File.exist?("/root/rpmbuild/RPMS/#{node['arch']}/#{rpm_file}") }
#   end
# end

rpm_package 'netatalk-one' do
  subscribes :install, 'ruby_block[find_built_rpms]', :immediately
  source nil
  options '-Uvh'
  package_name nil
  action :nothing
end

rpm_package 'netatalk-two' do
  subscribes :install, 'ruby_block[find_built_rpms]', :immediately
  source nil
  options '-Uvh'
  package_name nil
  action :nothing
end

rpm_package 'netatalk-three' do
  subscribes :install, 'ruby_block[find_built_rpms]', :immediately
  source nil
  options '-Uvh'
  package_name nil
  action :nothing
end
