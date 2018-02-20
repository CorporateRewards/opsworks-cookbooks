include_recipe "apache2"


node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  sess_path = "#{node[:codeigniter][:config][:sess_save_path]}/#{application}"
  cache_path = "#{node[:codeigniter][:config][:cache_path]}/#{application}"

  directory sess_path do
    mode 0755
    group node[:apache][:user]
    owner node[:apache][:user]
  end
  Chef::Log.info("Created Sessions directory: #{sess_path}")

  directory cache_path do
    mode 0755
    group node[:apache][:user]
    owner node[:apache][:user]
  end
  Chef::Log.info("Created Cache directory: #{cache_path}")

end
