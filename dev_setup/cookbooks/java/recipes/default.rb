#
# Cookbook Name:: java
# Recipe:: default
#
# Copyright 2011, VMware
#
#
package "python-software-properties"

case node['platform']
when "ubuntu","centos"
  package 'java'
# FIXME: add other major distro support
else
  Chef::Log.error("Installation of Sun Java packages not supported on this platform.")
end
