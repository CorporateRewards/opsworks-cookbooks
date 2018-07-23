
node[:deploy].each do |application, deploy|
  execute "yarn install" do
    command "cd $(ls -tdogl releases/* | awk '{print $7}' | head -n1) && yarn install"
  end
  cwd deploy["deploy_to"]
end
