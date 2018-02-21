include_recipe "deploy"


node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  if(deploy['deploy_to'] && File.directory?(deploy['deploy_to']))
    template "#{deploy[:deploy_to]}/shared/config/database.php" do
      source "db.erb"
      cookbook 'codeigniter'
      mode "0660"
      group deploy[:group]
      owner deploy[:user]
      variables(:database => deploy[:database])
    end
    Chef::Log.info("Created database template for #{application}")
    template "#{deploy[:deploy_to]}/shared/config/config.php" do
      source "config.erb"
      cookbook 'codeigniter'
      mode "0660"
      group deploy[:group]
      owner deploy[:user]
      variables(:config => node[:codeigniter][:config], :app => application)
    end
    Chef::Log.info("Created config template for #{application}")
  end
end
