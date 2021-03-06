#
# Cookbook Name:: owncloud
# Recipe:: default
#
# Copyright 2013, Onddo Labs, Sl.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Chef::Recipe.send(:include, OwnCloud::RecipeHelpers)

#==============================================================================
# Calculate dependencies for different distros
#==============================================================================

dbtype = node['owncloud']['config']['dbtype']

case node['platform']
when 'debian', 'ubuntu'
  # Sync apt package index
  include_recipe 'apt'

  php_pkgs = %w{ php5-gd php5-intl php5-curl smbclient }
  php_pkgs << 'php5-sqlite' if dbtype == 'sqlite'
  php_pkgs << 'php5-mysql' if dbtype == 'mysql'
  php_pkgs << 'php5-pgsql' if dbtype == 'pgsql'
when 'redhat', 'centos'
  if node['platform_version'].to_f < 6
    php_pkgs = %w{ php53-gd php53-mbstring php53-xml php53-intl samba-client }
    php_pkgs << 'php53-mysql' if dbtype == 'mysql'
    php_pkgs << 'php53-pgsql' if dbtype == 'pgsql'
    if dbtype == 'sqlite'
      Chef::Application.fatal!("SQLite database type not supported on #{node['platform']} 5.")
    end
  else
    php_pkgs = %w{ php-gd php-mbstring php-xml php-intl samba-client }
    php_pkgs << 'php-pdo' if dbtype == 'sqlite'
    php_pkgs << 'php-mysql' if dbtype == 'mysql'
    php_pkgs << 'php-pgsql' if dbtype == 'pgsql'
  end
when 'fedora', 'scientific', 'amazon'
  php_pkgs = %w{ php-gd php-mbstring php-xml php-intl samba-client }
  php_pkgs << 'php-pdo' if dbtype == 'sqlite'
  php_pkgs << 'php-mysql' if dbtype == 'mysql'
  php_pkgs << 'php-pgsql' if dbtype == 'pgsql'
else
  log('Unsupported platform, trying to guess packages.') { level :warn }
  php_pkgs = %w{ php-gd php-mbstring php-xml php-intl samba-client }
  php_pkgs << 'php-pdo' if dbtype == 'sqlite'
  php_pkgs << 'php-mysql' if dbtype == 'mysql'
  php_pkgs << 'php-pgsql' if dbtype == 'pgsql'
end

#==============================================================================
# Initialize autogenerated passwords
#==============================================================================

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

if Chef::Config[:solo]
  if node['owncloud']['config']['dbpassword'].nil? and node['owncloud']['config']['dbtype'] != 'sqlite'
    Chef::Application.fatal!('You must set owncloud\'s database password in chef-solo mode.')
  end
  if node['owncloud']['admin']['pass'].nil?
    Chef::Application.fatal!('You must set owncloud\'s admin password in chef-solo mode.')
  end
else
  unless node['owncloud']['config']['dbtype'] == 'sqlite'
    node.set_unless['owncloud']['config']['dbpassword'] = secure_password
  end
  node.set_unless['owncloud']['admin']['pass'] = secure_password
  node.save
end

#==============================================================================
# Install PHP
#==============================================================================

include_recipe 'php'

php_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

#==============================================================================
# Set up database
#==============================================================================

case node['owncloud']['config']['dbtype']
when 'sqlite'
  # With SQLite the table prefix must be oc_
  node.override['owncloud']['config']['dbtableprefix'] = 'oc_'
when 'mysql'
  if %w{ localhost 127.0.0.1 }.include?(node['owncloud']['config']['dbhost'])
    # Install MySQL
    include_recipe 'mysql::server'
    include_recipe 'database::mysql'

    mysql_connection_info = {
      :host => 'localhost',
      :username => 'root',
      :password => node['mysql']['server_root_password']
    }

    mysql_database node['owncloud']['config']['dbname'] do
      connection mysql_connection_info
      action :create
    end

    mysql_database_user node['owncloud']['config']['dbuser'] do
      connection mysql_connection_info
      database_name node['owncloud']['config']['dbname']
      host 'localhost'
      password node['owncloud']['config']['dbpassword']
      privileges [:all]
      action :grant
    end
  end
when 'pgsql'
  if %w{ localhost 127.0.0.1 }.include?(node['owncloud']['config']['dbhost'])
    # Install PostgreSQL
    include_recipe 'postgresql::server'
    include_recipe 'database::postgresql'

    postgresql_connection_info = {
      :host => 'localhost',
      :username => 'postgres',
      :password => node['postgresql']['password']['postgres']
    }

    postgresql_database node['owncloud']['config']['dbname'] do
      connection postgresql_connection_info
      action :create
    end

    postgresql_database_user node['owncloud']['config']['dbuser'] do
      connection postgresql_connection_info
      host 'localhost'
      password node['owncloud']['config']['dbpassword']
      action :create
    end

    postgresql_database_user node['owncloud']['config']['dbuser'] do
      connection postgresql_connection_info
      database_name node['owncloud']['config']['dbname']
      host 'localhost'
      password node['owncloud']['config']['dbpassword']
      privileges [:all]
      action :grant
    end
  end
else
  Chef::Application.fatal!("Unsupported database type: #{node['owncloud']['config']['dbtype']}")
end

#==============================================================================
# Set up mail transfer agent
#==============================================================================

if node['owncloud']['config']['mail_smtpmode'].eql?('sendmail') and
   node['owncloud']['install_postfix']

  include_recipe 'postfix::default'
end

#==============================================================================
# Download and extract ownCloud
#==============================================================================

directory node['owncloud']['www_dir']

unless node['owncloud']['deploy_from_git']
  basename = ::File.basename(node['owncloud']['download_url'])
  local_file = ::File.join(Chef::Config[:file_cache_path], basename)

  # Prior to Chef 11.6, remote_file does not support conditional get
  # so we do a HEAD http_request to mimic it
  http_request 'HEAD owncloud' do
    message ''
    url node['owncloud']['download_url']
    if Gem::Version.new(Chef::VERSION) < Gem::Version.new('11.6.0')
      action :head
    else
      action :nothing
    end
    if File.exists?(local_file)
      headers 'If-Modified-Since' => File.mtime(local_file).httpdate
    end
    notifies :create, 'remote_file[download owncloud]', :immediately
  end

  remote_file 'download owncloud' do
    source node['owncloud']['download_url']
    path local_file
    if Gem::Version.new(Chef::VERSION) < Gem::Version.new('11.6.0')
      action :nothing
    else
      action :create
    end
    notifies :run, 'bash[extract owncloud]', :immediately
  end

  bash 'extract owncloud' do
    code <<-EOF
      # remove previous installation if any
      if [ -d ./owncloud ]
      then
        pushd ./owncloud >/dev/null
        ls | grep -v 'data\\|config' | xargs rm -r
        popd >/dev/null
      fi
      # extract tar file
      tar xfj '#{local_file}' --no-same-owner
    EOF
    cwd node['owncloud']['www_dir']
    action :nothing
  end
else
  if node['owncloud']['git_ref']
    git_ref = node['owncloud']['git_ref']
  elsif node['owncloud']['version'].eql?('latest')
    git_ref = 'master'
  else
    git_ref = "v#{node['owncloud']['version']}"
  end

  git 'clone owncloud' do
    destination node['owncloud']['dir']
    repository node['owncloud']['git_repo']
    reference git_ref
    enable_submodules true
    action :sync
  end
end

#==============================================================================
# Set up webserver
#==============================================================================

# Get the webserver used
web_server = node['owncloud']['web_server']

# include the recipe for installing the webserver
case web_server
when 'apache'
  include_recipe 'owncloud::_apache'
  web_services = [ 'apache2' ]
when 'nginx'
  include_recipe 'owncloud::_nginx'
  web_services = [ 'nginx', 'php-fpm' ]
else
  Chef::Application.fatal!("Web server not supported: #{web_server}")
end

#==============================================================================
# Initialize configuration file and install ownCloud
#==============================================================================

# create required directories
[
  ::File.join(node['owncloud']['dir'], 'apps'),
  ::File.join(node['owncloud']['dir'], 'config'),
  node['owncloud']['data_dir']
].each do |dir|
  directory dir do
    owner node[web_server]['user']
    group node[web_server]['group']
    mode 00750
    action :create
  end
end

# create autoconfig.php for the installation
template 'autoconfig.php' do
  path ::File.join(node['owncloud']['dir'], 'config', 'autoconfig.php')
  source 'autoconfig.php.erb'
  owner node[web_server]['user']
  group node[web_server]['group']
  mode 00640
  variables(
    :dbtype => node['owncloud']['config']['dbtype'],
    :dbname => node['owncloud']['config']['dbname'],
    :dbuser => node['owncloud']['config']['dbuser'],
    :dbpass => node['owncloud']['config']['dbpassword'],
    :dbhost => node['owncloud']['config']['dbhost'],
    :dbprefix => node['owncloud']['config']['dbtableprefix'],
    :admin_user => node['owncloud']['admin']['user'],
    :admin_pass => node['owncloud']['admin']['pass'],
    :data_dir => node['owncloud']['data_dir']
  )
  not_if { ::File.exists?(::File.join(node['owncloud']['dir'], 'config', 'config.php')) }

  web_services.each do |web_service|
    notifies :restart, "service[#{web_service}]", :immediately
  end
  notifies :get, 'http_request[run setup]', :immediately
end

# install ownCloud
http_request 'run setup' do
  url 'http://localhost/'
  headers({ 'Host' => node['owncloud']['server_name'] })
  message ''
  action :nothing
end

# Apply the configuration on attributes to config.php
ruby_block 'apply config' do
  block do
    config_file = ::File.join(node['owncloud']['dir'], 'config', 'config.php')
    config = OwnCloud::Config.new(config_file)
    config.merge(node['owncloud']['config'])
    config.write
    unless Chef::Config[:solo]
      # store important options that where generated automatically by the setup
      node.set_unless['owncloud']['config']['passwordsalt'] = config['passwordsalt']
      node.set_unless['owncloud']['config']['instanceid'] = config['instanceid']
      node.save
    end
  end
end

#==============================================================================
# Enable cron for background jobs
#==============================================================================

if node['owncloud']['cron']['enabled'] == true
  cron 'owncloud cron' do
    user node[web_server]['user']
    minute node['owncloud']['cron']['min']
    hour node['owncloud']['cron']['hour']
    day node['owncloud']['cron']['day']
    month node['owncloud']['cron']['month']
    weekday node['owncloud']['cron']['weekday']
    command "php -f '#{node['owncloud']['dir']}/cron.php' >> '#{node['owncloud']['data_dir']}/cron.log' 2>&1"
  end
else
  cron 'owncloud cron' do
    user node[web_server]['user']
    command "php -f '#{node['owncloud']['dir']}/cron.php' >> '#{node['owncloud']['data_dir']}/cron.log' 2>&1"
    action :delete
  end
end
