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
cookbook_file "#{node[:nginx][:dir]}/sites-available/default" do
  mode '0644'
  owner 'root'
  group 'root'
  source 'munin-nginx.conf'
end

#start this site in nginx
execute "nxensite default" do
  command "/usr/sbin/nxensite default"
  notifies :reload, "service[nginx]"
  not_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") end
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
