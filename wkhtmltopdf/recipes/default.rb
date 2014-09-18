# ======================================
# = Script to wrap wkhtmltopdf in xvfb =
# ======================================
template '/usr/local/bin/wkhtmltopdf.sh' do
  source "wkhtmltopdf.sh"
  owner "deploy"
  mode "0755"
end