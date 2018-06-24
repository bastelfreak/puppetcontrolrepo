class profiles::puppetserver {
  # setup puppet master
  class{'puppet':
    server                         => true,
    show_diff                      => true,
    server_puppetserver_jruby9k    => true,
    server_foreman                 => true,
    server_strict_variables        => true,
    server_storeconfigs_backend    => 'puppetdb',
    server_reports                 => 'puppetdb,foreman',
    server_puppetdb_host           => $facts['fqdn'],
    server_foreman_url             => "https://${facts['fqdn']}",
    server_common_modules_path     => '', # dont create /etc/puppetlabs/code/environments/common, also purges basemodulepath from /etc/puppetlabs/puppet/puppet.conf
    server_environments            => [], # dont create /etc/puppetlabs/code/environments/{development,production}
    server_metrics_graphite_enable => true,
    server_metrics_graphite_host   => '127.0.0.1',
    server_metrics_graphite_port   => 9109,
  }

  include ferm

  ferm::rule{'allow_puppet':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '8140',
  }

  # provide endpoint to monitor nginx
  include nginx
  nginx::resource::server{'127.0.0.1':
    listen_ip => '127.0.0.1',
  }
  nginx::resource::location{'nginx_status':
    server              => '127.0.0.1',
    location            => '/nginx_status',
    stub_status         => true,
    index_files         => [],
    location_allow      => ['127.0.0.1'],
    location_deny       => ['all'],
    location_cfg_append => {'access_log' => 'off'},
    ssl                 => false,
  }

  class{'prometheus::graphite_exporter':
    options => '-web.listen-address localhost:9108',
  }

  class { 'r10k':
    version           => '2.6.2',
    sources           => {
      'puppet' => {
        'remote'  => 'https://github.com/bastelfreak/puppetcontrolrepo.git',
        'basedir' => $::settings::environmentpath,
        'prefix'  => false,
      },
    },
    manage_modulepath => false,
  }

  # add ourself with the public it to the hosts file
  # we can't use the host resource, it can't handle dualstack
  # also it would purge our entries that link the link-local addresses to our FQDN :(
  # we define them twice, because we don't have storeconfigs support during the first `puppet apply`
  #host{'host.local.ip':
  #  name    => 'puppet.local',
  #  ip      => $facts['networking']['ip6'],
  #  comment => 'MANAGED BY PUPPET',
  #}
  file_line{'hostlegacyip':
    path => '/etc/hosts',
    line => "${facts['networking']['ip']} puppet.local # MANAGED BY PUPPET",
  }
  file_line{'hostip':
    path => '/etc/hosts',
    line => "${facts['networking']['ip6']} puppet.local # MANAGED BY PUPPET",
  }
  @@file_line{'exporthostlegacyip':
    path => '/etc/hosts',
    line => "${facts['networking']['ip']} puppet.local # MANAGED BY PUPPET",
    tag  => 'puppetserver',
  }
  @@file_line{'exporthostip':
    path => '/etc/hosts',
    line => "${facts['networking']['ip6']} puppet.local # MANAGED BY PUPPET",
    tag  => 'puppetserver',
  }
}
