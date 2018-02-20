include_recipe "apache2"


node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  directory "#{node[:codeigniter][:sess_save_path]}/#{application}" do
    mode 0755
    group node[:apache][:user]
    owner node[:apache][:user]
  end

  directory "#{node[:codeigniter][:cache_path]}/#{application}" do
    mode 0755
    group node[:apache][:user]
    owner node[:apache][:user]
  end

end
