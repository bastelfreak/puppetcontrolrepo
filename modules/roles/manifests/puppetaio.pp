class rna::puppetaio {

  $foreman_db_password = '3<F3>4895y3e48otrhioer5htio45hut'
  $puppetdb_db_password = '349085u4589ye45uihtuieWE'

  # to generate the foreman admin login, run:
  # foreman-rake permissions:reset
  # create cache: foreman-rake apipie:cache
  # or get the current password from the cache:
  # awk '{print $2; exit}' /opt/puppetlabs/puppet/cache/foreman_cache_data/admin_password

  class { 'puppetdb::server':
    java_args         => {
      '-Xmx' => '8192m',
      '-Xms' => '2048m',
    },
    node_ttl          => '14d',
    node_purge_ttl    => '14d',
    report_ttl        => '999d',
    manage_firewall   => false,
    database_host     => '127.0.0.1',
    database_username => 'puppetdb',
    database_password => $puppetdb_db_password,
    database_name     => 'puppetdb',
    require           => Postgresql::Server::Db['puppetdb'],
  }

  # fix stupid selinux policy
  selinux::module{'foreman_tmu':
    ensure    => 'present',
    source_te => "puppet:///modules/${module_name}/configs/foreman_selinux.te",
  }

  # setup puppet master
  -> class{'puppet':
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

  # setup the database
  class{'postgresql::globals':
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
    manage_package_repo => true,
    version             => '10',
  }
  postgresql::server::db{'foreman':
    user     => 'foreman',
    password => postgresql_password($foreman_db_password, 'foreman'),
    owner    => 'foreman',
  }
  postgresql::server::db{'puppetdb':
    user     => 'puppetdb',
    password => postgresql_password($puppetdb_db_password, 'puppetdb'),
    owner    => 'puppetdb',
  }
  class { 'postgresql::server':

  }
  class{'foreman':
    db_manage       => false,
    db_password     => $foreman_db_password,
    dynflow_in_core => false,
    require         => Postgresql::Server::Db['foreman'],
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

  # run async tasks
  # https://github.com/theforeman/foreman-tasks
  contain foreman::plugin::tasks

  # this allows us to run custom hooks
  # https://github.com/theforeman/foreman_hooks
  contain foreman::plugin::hooks

  # allow nodes to set their own env
  # but still be authoritative for all other nodes
  # https://github.com/joshuabaird/foreman_noenv
  foreman::plugin{'noenv':
    package => 'tfm-rubygem-foreman_noenv',
  }

  # assign a default host group
  # https://github.com/theforeman/foreman_default_hostgroup
  contain foreman::plugin::default_hostgroup

  # setup docker support in foreman
  contain foreman::plugin::docker

  foreman::plugin{'column_view':
    package =>  'tfm-rubygem-foreman_column_view',
  }

  # foreman puppetdb
  # should be done after foreman is installed
  # should reload httpd
  class{'foreman::plugin::puppetdb':
    address => "https://${facts['fqdn']}:8081/pdb/cmd/v1",
  }

  # allow access to foreman/puppetserver
  ferm::rule{'allow_foreman_https':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '443',
  }
    ferm::rule{'allow_foreman_http':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '80',
  }
  ferm::rule{'allow_puppetserver':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '8140',
  }
}
