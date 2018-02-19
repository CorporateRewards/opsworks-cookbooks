include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  directory "#{deploy[:deploy_to]}/shared/cache" do
    mode 0660
    group deploy[:user]
    owner deploy[:user]
    action :create
  end

  directory "#{deploy[:deploy_to]}/shared/sessions" do
    mode 0660
    group deploy[:user]
    owner deploy[:user]
    action :create
  end

end
