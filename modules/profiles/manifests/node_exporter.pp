class profiles::node_exporter {
  file {'/var/lib/prometheus-dropzone':
    ensure => 'directory',
  }
  class { 'prometheus::node_exporter':
    version           => '0.16.0',
    collectors_enable => ['diskstats','filesystem','loadavg','meminfo','logind','netdev','netstat','stat','time','interrupts','tcpstat', 'textfile'],
    extra_options     => '--collector.textfile.directory=/var/lib/prometheus-dropzone --web.listen-address 127.0.0.1:9100',
    install_method    => 'url',
  }

  # provide endpoint to monitor node_exporter through ssl
  case $facts['os']['family'] {
    'RedHat': {
      $nginx = 'nginx'
      $ssl_protocols = 'TLSv1.2'
    }
    'Archlinux': {
      $nginx = 'http'
      $ssl_protocols = 'TLSv1.2 TLSv1.3'
    }
    'Debian': {
      $nginx = 'www-data'
      $ssl_protocols = 'TLSv1.2 TLSv1.3'
    }
  }
  include nginx
  file{"/etc/nginx/node_exporter_key_${trusted['certname']}.pem":
    ensure  => 'file',
    owner   => $nginx,
    group   => $nginx,
    mode    => '0400',
    source  => "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
    notify => Nginx::Resource::Server['node_exporter'],
  }
  file{"/etc/nginx/node_exporter_cert_${trusted['certname']}.pem":
    ensure => 'file',
    owner  => $nginx,
    group  => $nginx,
    mode   => '0400',
    source => "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
    notify => Nginx::Resource::Server['node_exporter'],
  }
  file{'/etc/nginx/node_exporter_puppet_crl.pem':
    ensure => 'file',
    owner  => $nginx,
    group  => $nginx,
    mode   => '0400',
    source => '/etc/puppetlabs/puppet/ssl/crl.pem',
    notify => Nginx::Resource::Server['node_exporter'],
  }
  file{'/etc/nginx/node_exporter_puppet_ca.pem':
    ensure => 'file',
    owner  => $nginx,
    group  => $nginx,
    mode   => '0400',
    source => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    notify => Nginx::Resource::Server['node_exporter'],
  }

  # that selboolean allows nginx to talk to tcp port 9100
  if $facts['os']['selinux']['enabled'] {
    selboolean{'httpd_enable_ftp_server':
      value      => 'on',
      persistent => true,
    }
  }
}
