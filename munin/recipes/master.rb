#
# Cookbook Name:: munin
# Recipe:: master
#
# Copyright 2016, Corporate Rewards
#
# All rights reserved - Do Not Redistribute
#

include_recipe "nginx"

# get the package installed
package 'munin' do
  action :install
end

# add our config file from a template
template "/etc/munin/munin.conf" do
  mode '0644'
  owner "root"
  group "root"
  source "munin-master.conf.erb"
end

# add a site for nginx to serve
template "#{node[:nginx][:dir]}/sites-available/munin" do
  mode '0644'
  owner 'root'
  group 'root'
  source 'munin-nginx.conf.erb'
  variables(:hostname => node["munin-master"]["hostname"], :html_dir => node["munin-master"]["html_dir"], :port => node["munin-master"]["port"])
end

#start this site in nginx
execute "nxensite munin" do
  command "/usr/sbin/nxensite default"
  notifies :reload, "service[nginx]"
  not_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/munin") end
end



#nginx_site "munin.conf" do 
#  enable true
#end

# start 'er up
service 'munin' do
  action [ :enable, :start ]
end

#service 'nginx' do
#  action :restart
#end
