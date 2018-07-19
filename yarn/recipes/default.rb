include_recipe 'apt'

apt_repository 'yarn' do
  uri          'https://dl.yarnpkg.com/debian'
  components   ['main', 'stable']
  key          'https://dl.yarnpkg.com/debian/pubkey.gpg'
end
