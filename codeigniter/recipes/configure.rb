include_recipe "apache2"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  directory "#{deploy[:deploy_to]}/shared/cache/#{application}" do
    mode 0660
    group node[:apache][:user]
    owner node[:apache][:user]
    recursive true
  end

  directory "#{deploy[:deploy_to]}/shared/sessions/#{application}" do
    mode 0660
    group node[:apache][:user]
    owner node[:apache][:user]
    recursive true
  end

end
