cron "job_name" do
  minute "2"
  command "echo 'Testing' > /tmp/test.txt"
end
