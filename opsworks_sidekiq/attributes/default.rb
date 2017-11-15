default['sidekiq'] = {}

default['sidekiq']['log_dir'] = 'tmp/pids'
default['sidekiq']['pid_dir'] = './log'
default['sidekiq']['rails_env'] = 'production'

default['sidekiq']['queues'] = {}
default['sidekiq']['queues']['default'] = 'config/sidekiq.yml'
