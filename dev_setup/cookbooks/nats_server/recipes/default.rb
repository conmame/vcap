#
# Cookbook Name:: nats
# Recipe:: default
#
# Copyright 2011, VMware
#

gem_package "nats" do
  gem_binary File.join(node[:ruby][:path], "bin", "gem")
  version "0.4.26"
end

nats_config_dir = File.join(node[:deployment][:config_path], "nats_server")
node[:nats_server][:config] = File.join(nats_config_dir, "nats_server.yml")

directory nats_config_dir do
  owner node[:deployment][:user]
  mode "0755"
  recursive true
  action :create
  notifies :restart, "service[nats_server]"
end

case node['platform']
when "ubuntu"

when "centos"

  bash "Install start-stop-daemon" do
    code <<-EOH
      cd /usr/local/src
      wget http://developer.axis.com/download/distribution/apps-sys-utils-start-stop-daemon-IR1_9_18-2.tar.gz
      tar xvzf apps-sys-utils-start-stop-daemon-IR1_9_18-2.tar.gz
      cd apps/sys-utils/start-stop-daemon-IR1_9_18-2/
      gcc start-stop-daemon.c -o start-stop-daemon
      cp start-stop-daemon /usr/sbin/
      hash -r
    EOH
    not_if do
      ::File.exists?(File.join("", "usr", "sbin", "start-stop-daemon"))
    end
  end

else
  Chef::Log.error("Installation of nats_server not supported on this platform.")
end


template "nats_server" do
  path File.join("", "etc", "init.d", "nats_server")
  source "nats_server.erb"
  owner node[:deployment][:user]
  mode 0755
  notifies :restart, "service[nats_server]"
end

service "nats_server" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "nats_server.yml" do
  path node[:nats_server][:config]
  source "nats_server.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  notifies :restart, "service[nats_server]"
end
