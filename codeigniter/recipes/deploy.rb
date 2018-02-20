include_recipe "deploy"

Chef::Log.info("Chef deploy:")
Chef::Log.info(deploy)

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  template "#{deploy[:deploy_to]}/shared/config/#{application}/database.php" do
    source "db.erb"
    cookbook 'codeigniter'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database])
  end

  template "#{deploy[:deploy_to]}/shared/config/#{application}/config.php" do
    source "config.erb"
    cookbook 'codeigniter'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:config => node[:codeigniter][:config], :app => application)
  end
end
