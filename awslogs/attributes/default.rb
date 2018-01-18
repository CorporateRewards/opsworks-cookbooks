default[:cwlogs][:logfile] = '/var/log/aws/opsworks/opsworks-agent.log'
default[:cwlogs][:region] = 'eu-west-1'

default[:cwlogs][:streams] = {}

default[:cwlogs][:streams]['kernel'] = {}
default[:cwlogs][:streams]['kernel']['path'] = '/var/log/kern.log'
default[:cwlogs][:streams]['kernel']['name'] = 'kern.log'
default[:cwlogs][:streams]['kernel']['datetime_format'] = '%b %d %H:%M:%S'

default[:cwlogs][:streams]['syslog'] = {}
default[:cwlogs][:streams]['syslog']['path'] = '/var/log/syslog'
default[:cwlogs][:streams]['syslog']['name'] = 'syslog'
default[:cwlogs][:streams]['syslog']['datetime_format'] = '%b %d %H:%M:%S'

default[:cwlogs][:streams]['auth'] = {}
default[:cwlogs][:streams]['auth']['path'] = '/var/log/auth.log'
default[:cwlogs][:streams]['auth']['name'] = 'auth.log'
default[:cwlogs][:streams]['auth']['datetime_format'] = '%b %d %H:%M:%S'

if node['nginx'] && node['nginx']['log_format'].empty?
  default[:cwlogs][:streams]['nginx'] = {}
  default[:cwlogs][:streams]['nginx']['path'] = "/var/log/nginx/#{node['opsworks']['applications'][0]['slug_name']}.access.log"
  default[:cwlogs][:streams]['nginx']['name'] = 'nginx_access.log'
  default[:cwlogs][:streams]['nginx']['datetime_format'] = '[%Y/%m/%d %H:%M:%S]'
elseif node['nginx'] && node['nginx']['log_format'].empty?
  node['nginx']['log_format'].each do |name, format|
    default[:cwlogs][:streams]['nginx'] = {}
    default[:cwlogs][:streams]['nginx']['path'] = "/var/log/nginx/#{node['opsworks']['applications'][0]['slug_name']}.#{name}.access.log"
    default[:cwlogs][:streams]['nginx']['name'] = 'nginx_access.log'
    default[:cwlogs][:streams]['nginx']['datetime_format'] = '[%Y/%m/%d %H:%M:%S]'
 end
end

default[:cwlogs][:streams]['rails'] = {}
default[:cwlogs][:streams]['rails']['path'] = "/srv/www/#{node['opsworks']['applications'][0]['slug_name']}/shared/log/#{node["deploy"][node["opsworks"]["applications"][0]["slug_name"]]["rails_env"]}.log"
default[:cwlogs][:streams]['rails']['name'] = 'rails.log'
default[:cwlogs][:streams]['rails']['datetime_format'] = '[%Y-%m-%dT%H:%M:%S]'

default[:cwlogs][:streams]['sidekiq'] = {}
default[:cwlogs][:streams]['sidekiq']['path'] = "/srv/www/#{node['opsworks']['applications'][0]['slug_name']}/shared/log/sidekiq.log"
default[:cwlogs][:streams]['sidekiq']['name'] = 'sidekiq.log'
default[:cwlogs][:streams]['sidekiq']['datetime_format'] = '[%Y-%m-%dT%H:%M:%S]'
