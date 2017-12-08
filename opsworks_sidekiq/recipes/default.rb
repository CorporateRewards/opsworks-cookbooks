#
# Cookbook Name:: opsworks_sidekiq
# Recipe:: default
#
#
#

node[:deploy].each do |application, deploy|
  vars={}
  deploy[:environment_variables].each do |key, value|
    vars[key] = value
  end

  node['sidekiq']['queues'].each do |name, config|
    puts "Got config for Sidekiq Queue - #{name} => #{config}"
    opsworks_sidekiq "#{name}" do
      config config
      queue_name name
      working_directory "/srv/www/#{application}/current"
      rails_env node[:rails_env]
      user "deploy"
      group "www-data"
      vars vars
    end
  end
end
