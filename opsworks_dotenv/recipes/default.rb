# @Author: Ted Moyses
# @Date:   2017-10-17T22:58:21+01:00
# @Email:  ted.moyses@corporaterewards.co.uk
# @Filename: default.rb
# @Last modified by:   Ted Moyses
# @Last modified time: 2017-10-18T02:43:20+01:00

node[:deploy].each do |application, deploy|
  vars={}
  deploy[:environment_variables].each do |key, value|
    vars[key] = value
  end

  template "#{node[:deploy_to]}/current/.env" do
    source 'dotenv.erb'
    mode 0440
    owner deploy[:user]
    group deploy[:group]
    variables ({:vars => vars})
  end
end
