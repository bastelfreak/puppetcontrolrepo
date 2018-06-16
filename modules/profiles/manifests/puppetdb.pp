class profiles::puppetdb {
  class { 'puppetdb':
    #java_args              => {
      #'-Xmx' => '8192m',
      #'-Xms' => '2048m',
      #    },
    node_ttl                => '14d',
    node_purge_ttl          => '14d',
    report_ttl              => '999d',
    manage_firewall         => false,
    manage_dbserver         => true,
    postgres_version        => '10',
    ssl_deploy_certs        => true,
    ssl_set_cert_paths      => true,
    disable_update_checking => true,
    ssl_key                 => "/etc/puppetlabs/puppet/ssl/private_keys/${facts['fqdn']}.pem",
    ssl_cert                => "/etc/puppetlabs/puppet/ssl/certs/${facts['fqdn']}.pem",
    ssl_ca_cert             => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
  }
}
