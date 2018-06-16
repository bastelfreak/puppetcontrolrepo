class roles::puppetserver {
  # foreman plugins depends on puppetdb
  # foreman_proxy depends on foreman (which can be installed on a different node, that's why this is a single profile)
  # maybe it's a good idea to install puppetserver before the proxy
  include profiles::puppetserver
  include profiles::puppetserverproxy
  include profiles::puppetdb
  include profiles::foreman
  Class['profiles::Puppetserver']
  -> Class['Profiles::Puppetdb']
  -> Class['Profiles::Foreman']
  -> Class['Profiles::Puppetserverproxy']
}
