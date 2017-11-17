# @Date:   2017-11-15T10:53:04+00:00
# @Last modified time: 2017-11-17T09:19:27+00:00



actions :create
default_action :create

attribute :working_directory, :kind_of => [String, NilClass], :required => true

attribute :user, :kind_of => [String], :required => true
attribute :group, :kind_of => [String, NilClass], :default => 'root'

attribute :pid_dir, :kind_of => [String, NilClass], :default => nil
attribute :log_dir, :kind_of => [String, NilClass], :default => nil
attribute :rails_env, :kind_of => [String, NilClass], :default => nil

attribute :queue_name, :kind_of => [String], :required => true
attribute :config, :kind_of => [String], :required => true
