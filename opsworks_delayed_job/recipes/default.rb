#
# Cookbook Name:: opsworks_sidekiq
# Recipe:: default
#
#
#

node[:deploy].each do |application, deploy|
  opsworks_delayed_job 'delayed_job' do
    vars={}
    deploy[:environment_variables].each do |key, value|
      vars[key] = value
    end
    working_directory "/srv/www/#{application}/current"
    rails_env deploy[:rails_env]
    user "deploy"
    group "www-data"
    vars vars
  end
end
