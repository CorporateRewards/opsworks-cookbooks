
action :create do
  name       = new_resource.name
  user       = new_resource.user
  group      = new_resource.group
  rails_root = new_resource.working_directory
  rails_env  = new_resource.rails_env 
  
  execute "reload-monit-for-delayed-job" do
    command "monit -Iv reload"
    action :nothing
  end

  directory new_resource.pid_dir do
    owner user
    group group
    mode 0750
  end

  directory new_resource.log_dir do
    mode 0750
  end

  file "#{new_resource.log_dir}/delayed_job.log" do
    owner user
    group group
    mode 0640
    action :create_if_missing
  end

  Chef::Log.info("Starting Delayed Job config")

  template "/usr/local/bin/stop_delayed_job.sh" do
    source 'stop.sh.erb'
    cookbook 'opsworks_delayed_job'
    owner user
    group group
    mode 0755
    variables "rails_env" => rails_env,
	    "pid_file" => "#{pid_dir}/delayed_job.pid",
            "rails_root" => rails_root,
	    "user" => user
  end

  template "/usr/local/bin/start_delayed_job.sh" do
    source 'start.sh.erb'
    cookbook 'opsworks_delayed_job'
    owner user
    group group
    mode 0755
    variables "rails_env" => rails_env,
	    "pid_file" => "#{pid_dir}/delayed_job.pid",
            "rails_root" => rails_root,
	    "user" => user
  end

  template "#{node.default["monit"]["conf_dir"]}/delayed_job.monitrc" do
    source 'monitrc.erb'
    cookbook 'opsworks_delayed_job'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, "execute[reload-monit-for-delayed-job]", :immediately # Run immediately to ensure the following command works
    variables "pid_file" => "#{pid_dir}/delayed_job.pid"
  end

  # Restart sidekiq if it's already running
  execute "restart-delayed-job-service" do
    command "monit -Iv restart delayed_job"
    #only_if { ::File.exists?(pid_file) }
    retries 1
    # notifies :run, "execute[reload-monit-for-sidekiq]", :before #again attempt to force a reload of monit config...
  end

  new_resource.updated_by_last_action(true)
end
