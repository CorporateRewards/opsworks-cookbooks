cron_d "cron_test" do
  minute "2"
  command "echo 'Testing' > /tmp/test.txt"
  user "deploy"
end
