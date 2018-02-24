node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  if node[:deploy].length == 1
    application = ""
  end

  streams = node[:cwlogs][:streams]

  if deploy[:cwlogs] && deploy[:cwlogs][:streams]
    streams = streams.merge(deploy[:cwlogs][:streams]) {|key, fromnode, fromdeploy| fromnode.merge fromdeploy}
  end

  #Chef::Log.info("Debug streams:")
  #Chef::Log.info(deploy[:cwlogs][:streams])
  #Chef::Log.info(streams)


  template "/tmp/cwlogs.cfg" do
    cookbook "awslogs"
    source "cwlogs.cfg.erb"
    owner "root"
    group "root"
    mode 0644
    variables(:streams => streams, :application => application, :deploy_to => deploy[:deploy_to])
  end
end
