site :opscode

def opsworks_cookbook(name, version = '>= 0.0.0', options = {})
  cookbook name, version, { path: "/a/volcanic/opsworks-cookbooks/#{name}" }.merge(options)
end

#opsworks_cookbook 'apt'
#opsworks_cookbook 'build-essential'
#opsworks_cookbook 'database'
#opsworks_cookbook 'php-fpm'
#opsworks_cookbook 'postfix'

cookbook 'database'
cookbook 'php-fpm'
cookbook 'postfix'
