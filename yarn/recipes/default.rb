include_recipe 'apt'

apt_repository 'yarn' do
  uri          'https://dl.yarnpkg.com/debian/'
  components   ['stable', 'main']
  key          'https://dl.yarnpkg.com/debian/pubkey.gpg'
end

node[:deploy].each do |application, deploy|
  directory deploy["deploy_to"] + '/shared/node_modules' do
    mode 0755
    owner 'deploy'
    group 'www-data'
    action :create
  end
end

package 'Install yarn' do
  package_name 'yarn'
end
