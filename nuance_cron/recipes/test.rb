

template '/etc/cron.d/test' do
  source 'test.erb'
  owner 'root'
  group 'root'
  mode '0754'
end
