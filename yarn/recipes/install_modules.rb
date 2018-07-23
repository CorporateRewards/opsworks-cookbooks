
node[:deploy].each do |application, deploy|
  execute "yarn install" do
    command "cd $(ls -tdogl releases/* | awk '{print $7}' | head -n1) && yarn install"
    cwd deploy["deploy_to"]
  end
end
