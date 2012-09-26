#
# Cookbook Name:: stager
# Recipe:: default
#
# Copyright 2012, VMware
#

package "curl"

template node[:stager][:config_file] do
  path File.join(node[:deployment][:config_path], node[:stager][:config_file])
  source "stager.yml.erb"
  owner node[:deployment][:user]
  mode 0644
end

template "vcap_redis.conf" do
  path File.join(node[:deployment][:config_path], "vcap_redis.conf")
  source "vcap_redis.conf.erb"
  owner node[:deployment][:user]
  mode 0644
end

case node['platform']
when "ubuntu"
  template "vcap_redis" do
    path File.join("", "etc", "init.d", "vcap_redis")
    source "vcap_redis.erb"
    owner node[:deployment][:user]
    mode 0755
  end
when "centos"
  template "vcap_redis_centos" do
    path File.join("", "etc", "init.d", "vcap_redis")
    source "vcap_redis_centos.erb"
    owner node[:deployment][:user]
    mode 0755
  end
end

service "vcap_redis" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end

template node[:stager][:platform] do
  path File.join(node[:deployment][:config_path], node[:stager][:platform])
  source "platform.yml.erb"
  owner node[:deployment][:user]
  mode 0644
end

cf_bundle_install(File.expand_path("stager", node[:cloudfoundry][:home]))
