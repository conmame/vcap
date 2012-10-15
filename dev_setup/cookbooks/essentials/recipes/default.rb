#
# Cookbook Name:: essentials
# Recipe:: default
#
# Copyright 2011, VMWARE
#
#

case node['platform']
when "ubuntu"
  %w{apt-utils build-essential libssl-dev
     libxml2 libxml2-dev libxslt1.1 libxslt1-dev git-core sqlite3 libsqlite3-ruby
     libsqlite3-dev unzip zip ruby-dev libmysql-ruby libmysqlclient-dev libcurl4-openssl-dev}.each do |p|
    package p do
      action [:install]
    end
  end

  machine =  node[:kernel][:machine]
  libpq_deb_path = File.join(node[:deployment][:setup_cache], "libpq5_9.2.deb")
  cf_remote_file libpq_deb_path do
    owner node[:deployment][:user]
    id node[:postgresql][:id][:libpq]["#{machine}"]
    checksum node[:postgresql][:checksum][:libpq]["#{machine}"]
  end

  libpq_dev_deb_path = File.join(node[:deployment][:setup_cache], "libpq-dev_9.2.deb")
  cf_remote_file libpq_dev_deb_path do
    owner node[:deployment][:user]
    id node[:postgresql][:id][:libpq_dev]["#{machine}"]
    checksum node[:postgresql][:checksum][:libpq_dev]["#{machine}"]
  end

  bash "Install libpq" do
    code <<-EOH
    dpkg -i #{libpq_deb_path}
    EOH
  end

  bash "Install libpq-dev" do
    code <<-EOH
    dpkg -i #{libpq_dev_deb_path}
    EOH
  end

when "centos"
  bash "Install epel" do
    code <<-EOH
    sudo rpm -ivh --force http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-7.noarch.rpm
    EOH
  end

  %w{openssl-devel
     libxml2 libxml2-devel libxslt libxslt-devel git-core sqlite ruby-sqlite3
     sqlite-devel unzip zip ruby-devel ruby-mysql mysql-devel libcurl-devel postgresql-libs postgresql-devel}.each do |p|
    package p do
      action [:install]
    end
  end
end

if node[:deployment][:profile]
  file node[:deployment][:profile] do
    owner node[:deployment][:user]
    group node[:deployment][:group]
    content "export PATH=#{node[:ruby][:path]}/bin:`#{node[:ruby][:path]}/bin/gem env gempath`/bin:$PATH"
  end
end
