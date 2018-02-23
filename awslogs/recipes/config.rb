
node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  if node[:deploy].length == 1
    application = ""
  end
  if deploy[:cwlogs][:streams]
    node[:cwlogs][:streams].merge(deploy[:cwlogs][:streams])
  end
  template "/tmp/cwlogs.cfg" do
    cookbook "awslogs"
    source "cwlogs.cfg.erb"
    owner "root"
    group "root"
    mode 0644
    variables(:streams => node[:cwlogs][:streams], :application => application, :deploy_to: => deploy[:deploy_to])
  end
end
