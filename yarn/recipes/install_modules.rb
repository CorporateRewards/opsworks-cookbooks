node[:deploy].each do |application, deploy|
  execute "yarn install" do
    command "yarn install"
    subscribes :create, resources(:template => "#{node[:deploy][application][:deploy_to]}/shared/config/database.yml")
  end
end
