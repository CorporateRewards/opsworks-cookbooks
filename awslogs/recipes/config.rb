def copy_stream (stream, application="", deploy_to=nil)
  output = {}
  stream.each do |key, value|
    output[key] = value
  end
  output["application"] = application
  output["deploy_to"] = deploy_to
  return output
end

streams = []

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  node[:cwlogs][:streams].each do |key, value|
    streams.push (copy_stream value,application, deploy[:deploy_to])
  end

  #set application name to a blank string if we are the first and only application
  if node[:deploy].length == 1
    application = ""
  end

  # loop each stream we have and copy to out list of streams
  if deploy[:cwlogs] && deploy[:cwlogs][:streams]
    deploy[:cwlogs][:streams].each do |key, stream|
      streams.push(copy_stream stream, application, deploy[:deploy_to])
    end
  end
end

Chef::Log.info("Found the following streams to process:")
Chef::Log.info(streams)

template "/tmp/cwlogs.cfg" do
  cookbook "awslogs"
  source "cwlogs.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables(:streams => streams)
end
