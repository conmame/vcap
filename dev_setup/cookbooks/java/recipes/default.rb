#
# Cookbook Name:: java
# Recipe:: default
#
# Copyright 2011, VMware
#
#

case node['platform']
when "ubuntu"
	package "python-software-properties"
end

package 'java'

case node['platform']
when "ubuntu"
	
when "centos"
	package "java-1.5.0-gcj"
else
  Chef::Log.error("Installation of Sun Java packages not supported on this platform.")
end
