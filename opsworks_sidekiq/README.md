OpsWorks Sidekiq Cookbook
===========================

## Description

This cookbook is for AWS OpsWorks running linux hosts to deploy sidekiq under monit control

## Requirements

*   Chef 11 (might work on Chef 0.9)
*   Sidekiq config files must be YAML
*   Config path is relative to rails root with leading slash
*   All paths in sidekiq config (i.e. log and pid files) must be relative to rails root


## Node Attributes


## Resource Attributes


## Usage

```ruby
opsworks_sidekiq "name" do
  config "/path/to/config/in/source.yml"
  queue_name "name of queue in config file"
  working_directory "/srv/path/to/app/current"
  rails_env "production"
  user "deploy"
  group "deploy"
end
```
