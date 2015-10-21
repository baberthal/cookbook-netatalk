#
# Cookbook Name:: netatalk
# Recipe:: jessie
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
base_url = node['netatalk']['jessie']['pkg_base_url']

directory "#{cache_path}/netatalk" do
  recursive true
end

package node['netatalk']['jessie']['dependencies'] do
  action :install
end

node['netatalk']['jessie']['packages'].each do |pkg|
  remote_file "#{cache_path}/netatalk/#{pkg[:name]}" do
    source "#{base_url}/#{pkg[:name]}"
    checksum pkg[:checksum]
  end

  dpkg_package pkg[:name] do
    action :install
    source "#{cache_path}/netatalk/#{pkg[:name]}"
  end
end
