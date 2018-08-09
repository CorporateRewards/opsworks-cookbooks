cron_d "nuance_user_import" do
  hour "7"
  minute "5"
  command "cd /srv/www/nuancev3/current && php index.php tools/trigger_user_update"
  user "deploy"
end
