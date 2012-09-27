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
  %w{java-1.6.0-openjdk java-1.6.0-openjdk-devel}.each do |pkg|
    package pkg
  end
else
  Chef::Log.error("Installation of Sun Java packages not supported on this platform.")
end
