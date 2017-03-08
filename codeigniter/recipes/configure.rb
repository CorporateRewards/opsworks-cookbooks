include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  directory "#{deploy[:deploy_to]}/shared/tmp" do
    mode 0755
    group deploy[:group]
    owner deploy[:user]
    action :create
  end

  template "#{deploy[:deploy_to]}/shared/config/database.php" do
    source "db.erb"
    cookbook 'codeigniter'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database])
  end

  template "#{deploy[:deploy_to]}/shared/config/config.php" do
    source "config.erb"
    cookbook 'codeigniter'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:config => node[:codeigniter][:config])
  end
end
