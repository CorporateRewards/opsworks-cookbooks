#
# Cookbook Name:: munin
# Recipe:: default
#
# Copyright 2016, Corporate Rewards
#
# All rights reserved - Do Not Redistribute
#

# get the package installed
package 'munin-node' do
  action :install
end

# add our config file from a template
template "/etc/munin/munin-node.conf" do
  mode '0644'
  owner "root"
  group "root"
  source "munin-node.conf.erb"
end

# add any extra plugins - if they and their congig exist
node["munin"]["plugins"].each do |plugin|
  cookbook_file "/usr/local/munin/plugins/#{plugin}" do
    only_if { run_context.has_cookbook_file_in_cookbook?(cookbook_name, "plugin/#{plugin}") }
    mode 0644
    source "plugins/#{plugin}"
  end
  cookbook_file "/usr/local/munin/plugins/zzz_opsworks_#{plugin_conf}.conf" do
    only_if { run_context.has_cookbook_file_in_cookbook?(cookbook_name, "plugin/#{plugin_conf}.conf") }
    mode 0644
    source "plugins/#{plugin}.conf"
  end
end

# run the oneliner to configure munin
execute "munin-node-configure" do
  command "munin-node-configure --shell --families=contrib,auto | sh -x"
end

# start 'er up
service 'munin-node' do
  action [ :enable, :start ]
end


