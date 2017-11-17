# @Date:   2017-11-15T10:53:04+00:00
# @Last modified time: 2017-11-17T09:42:08+00:00



#
# Cookbook Name:: opsworks_sidekiq
# Recipe:: default
#
#

node[:deploy].each do |application, deploy|

  node['sidekiq']['queues'].each do |name, config|
    puts "Got config for Sidekiq Queue - #{name} => #{config}"
    opsworks_sidekiq "#{name}" do
      config config
      queue_name name
      working_directory "/srv/www/#{application}/current"
      rails_env node[:rails_env]
      user "deploy"
      group "www-data"
    end
  end
end
