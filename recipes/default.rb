#
# Cookbook Name:: netatalk
# Recipe:: default
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

case node['netatalk']['install_method']
when 'package'
  if node['platform'] =~ /debian/i && node['platform_version'].to_f >= 8.0
    include_recipe 'netatalk::jessie'
  else
    package node['netatalk']['package_name']
  end
when 'rpm-src'
  include_recipe 'netatalk::rpm_src'
when 'source'
  include_recipe 'netatalk::source'
when 'deb_build'
  include_recipe 'netatalk::deb_build'
end

service 'avahi-daemon' do
  action [:enable, :start]
  supports status: true, restart: true, reload: true
end

service 'netatalk' do
  action [:enable, :start]
  supports status: true, restart: true, reload: true
end
