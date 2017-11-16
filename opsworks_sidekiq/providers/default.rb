action :create do
  name       = new_resource.name
  user       = new_resource.user
  group      = new_resource.group
  rails_root = new_resource.working_directory
  rails_env  = new_resource.rails_env || node['sidekiq']['rails_env']

  config      = new_resource.config || node['sidekiq']['config']
  queue_name = ::File.basename(config, ".yml")
  pid_dir    = new_resource.pid_dir || node['sidekiq']['pid_dir']
  log_dir    = new_resource.log_dir || node['sidekiq']['log_dir']

  pid_file   = "#{pid_dir}/sidekiq.#{queue_name}.pid"
  log_file   = "#{log_dir}/sidekiq.#{queue_name}.log"

  execute "reload-monit-for-sidekiq" do
    command "monit -Iv reload"
    action :nothing
  end

  directory pid_dir do
    owner user
    group group
    mode 0775
  end

  directory log_dir do
    mode 0775
  end

  file log_file do
    owner user
    group group
    mode 0755
    action :create_if_missing
  end

  template "/usr/local/bin/stop_sidekiq_#{queue_name}.sh" do
    source 'stop_sidekiq.sh.erb'
    cookbook 'opsworks_sidekiq'
    owner user
    group group
    mode 0755
    variables "pid_dir" => pid_dir,
              "log_dir" => log_dir,
              "user" => user,
              "queue_name" => queue_name,
              "rails_root" => rails_root,
              "rails_env" => rails_env,
              "config" => config
  end

  template "/usr/local/bin/start_sidekiq_#{queue_name}.sh" do
    source 'start_sidekiq.sh.erb'
    cookbook 'opsworks_sidekiq'
    owner user
    group group
    mode 0755
    variables "pid_dir" => pid_dir,
              "log_dir" => log_dir,
              "user" => user,
              "queue_name" => queue_name,
              "rails_root" => rails_root,
              "rails_env" => rails_env,
              "config" => config
  end

  template "#{node.default["monit"]["conf_dir"]}/sidekiq_#{queue_name}.monitrc" do
    source 'sidekiq.monitrc.erb'
    cookbook 'opsworks_sidekiq'
    owner 'root'
    group 'root'
    mode '0644'
    variables "name" => name,
              "pid_file" => pid_file
    notifies :run, "execute[reload-monit-for-sidekiq]", :immediately # Run immediately to ensure the following command works
  end

  # Restart sidekiq if it's already running
  execute "restart-sidekiq-service" do
    command "monit -Iv restart sidekiq_#{queue_name}"
    only_if { ::File.exists?(pid_file) }
  end

  new_resource.updated_by_last_action(true)
end
