module NodeInstall
  def cf_node_install(node_version, node_source_id, node_path, node_npm=nil)
    case node['platform']
    when "ubuntu"
      %w[ build-essential ].each do |pkg|
        package pkg
      end
    end

    tarball_path = File.join(node[:deployment][:setup_cache], "node-v#{node_version}.tar.gz")
    cf_remote_file tarball_path do
      owner node[:deployment][:user]
      id node_source_id
      checksum node[:node][:checksums][node_version]
    end

    directory node_path do
      owner node[:deployment][:user]
      group node[:deployment][:group]
      mode "0755"
      recursive true
      action :create
    end

    build_option = ""
    case node['platform']
    when "centos"
      build_option = "CFLAGS+=-O2 CXXFLAGS+=-O2" if node_version == "0.8.2"
    end

    bash "Install Node.js version " + node_version do
      cwd File.join("", "tmp")
      user node[:deployment][:user]
      code <<-EOH
      tar xzf #{tarball_path}
      cd node-v#{node_version}
      ./configure --prefix=#{node_path}
      make #{build_option}
      make install #{build_option}
      EOH
    end

    minimal_npm_bundled_node_version = "0.6.3"

    if Gem::Version.new(node_version) < Gem::Version.new(minimal_npm_bundled_node_version)

      npm_tarball_path = File.join(node[:deployment][:setup_cache], "npm-#{node_npm[:version]}.tgz")
      cf_remote_file npm_tarball_path do
        owner node[:deployment][:user]
        id node_npm[:id]
        checksum node_npm[:checksum]
      end

      directory node_npm[:path] do
        owner node[:deployment][:user]
        group node[:deployment][:group]
        mode "0755"
        recursive true
        action :create
      end

      bash "Install npm version " + node_npm[:version] do
        cwd File.join("", "tmp")
        user node[:deployment][:user]
        code <<-EOH
        tar xzf #{npm_tarball_path} --directory=#{node_npm[:path]} --strip-components=1
        EOH
      end
    end

  end
end

class Chef::Recipe
  include NodeInstall
end
