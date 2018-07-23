
node[:deploy].each do |application, deploy|
  execute "yarn install" do
    command "yarn install"
  end
end
