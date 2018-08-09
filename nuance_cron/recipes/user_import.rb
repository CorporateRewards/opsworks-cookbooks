

template '/etc/cron.d/nuance_user_import' do
  source 'nuance_user_import.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
