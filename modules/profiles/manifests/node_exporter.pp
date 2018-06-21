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

  # that selboolean allows nginx to talk to tcp port 9100
  if $facts['os']['selinux']['enabled'] {
    selboolean{'httpd_enable_ftp_server':
      value      => 'on',
      persistent => true,
    }
  }
}
