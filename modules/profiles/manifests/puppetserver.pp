class profiles::puppetserver {
  # setup puppet master
  class{'puppet':
    server                      => true,
    show_diff                   => true,
    server_puppetserver_jruby9k => true,
    server_foreman              => true,
    server_strict_variables     => true,
    server_storeconfigs_backend => true,
    server_reports              => 'puppetdb,foreman',
    server_puppetdb_host        => $facts['fqdn'],
    server_foreman_url          => "https://${facts['fqdn']}",
  }
  class{'foreman_proxy':
    puppet           => true,
    puppetca         => true,
    tftp             => false,
    dhcp             => false,
    dns              => false,
    bmc              => false,
    realm            => false,
    foreman_base_url => "https://${facts['fqdn']}",
    trusted_hosts    => ['puppet', $facts['fqdn']],
  }

}
