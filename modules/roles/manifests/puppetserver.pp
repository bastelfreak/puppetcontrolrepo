class roles::puppetserver {
  include profiles::puppetserver
  include profiles::puppetdb
  include profiles::foreman
  Class['Profiles::Puppetserver']
  -> Class['Profiles::Foreman']
}
