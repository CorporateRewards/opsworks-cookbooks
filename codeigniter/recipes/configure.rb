include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  template "#{release_path}/application/config/database.php" do
    source "db.erb"
    cookbook 'codeigniter'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database])

  end
end
