class profiles::puppetdb {
  class { 'puppetdb::server':
    #java_args         => {
      #'-Xmx' => '8192m',
      #'-Xms' => '2048m',
      #    },
    node_ttl          => '14d',
    node_purge_ttl    => '14d',
    report_ttl        => '999d',
    manage_firewall   => false,
  }
}
