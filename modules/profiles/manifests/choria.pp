# this class configures a choria agent
# you want to put this on a single node, maybe your puppetserver
class profiles::choria {
  contain mcollective
  sysctl {'net.core.somaxconn':
    ensure  => present,
    value   => '4092',
    comment => 'test',
    notify  => Service['gnatsd'],
  }
  sysctl {'net.ipv4.tcp_max_syn_backlog':
    ensure  => present,
    value   => '8192',
    comment => 'test',
    notify  => Service['gnatsd'],
  }
}
