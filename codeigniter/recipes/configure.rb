include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  directory "#{deploy[:deploy_to]}/shared/cache/#{application}" do
    mode 0660
    group deploy[:user]
    owner deploy[:user]
    recursive: true
  end

  directory "#{deploy[:deploy_to]}/shared/sessions#{application}" do
    mode 0660
    group deploy[:user]
    owner deploy[:user]
    recursive: true
  end

end
