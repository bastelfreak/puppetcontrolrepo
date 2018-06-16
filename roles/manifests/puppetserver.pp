class roles::puppetserver {
  include profiles::puppetserver
  include profiles::foreman
  Class['Profiles::Puppetserver']
  -> Class['Profiles::Foreman']
}
