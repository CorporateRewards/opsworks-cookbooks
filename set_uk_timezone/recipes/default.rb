# =====================================
# = Long description for the timezone =
# =====================================
template '/etc/timezone' do
  source "timezone"
end

# =============================================
# = Set the local timezone to 'Europe/London' =
# =============================================
execute 'configure timezone' do
  command "dpkg-reconfigure --frontend noninteractive tzdata"
end