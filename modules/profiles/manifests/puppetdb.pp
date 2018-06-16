class profiles::puppetdb {
  # setup the database
  class{'postgresql::globals':
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
    manage_package_repo => true,
    version             => '10',
  }
  -> class { 'puppetdb':
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
