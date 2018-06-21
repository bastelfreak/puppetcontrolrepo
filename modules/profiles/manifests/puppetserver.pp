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
    server_common_modules_path  => '', # dont create /etc/puppetlabs/code/environments/common, also purges basemodulepath from /etc/puppetlabs/puppet/puppet.conf
    server_environments         => [] # dont create /etc/puppetlabs/code/environments/{development,production}
  }

  include ferm

  ferm::rule{'allow_puppet':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '8140',
  }

   # provide endpoint to monitor nginx
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
}
