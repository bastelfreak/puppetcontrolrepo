# this class configures a choria client
# you want to put this on a single node, maybe your puppetserver
class profiles::choriaclient {
  include choria::broker
  sysctl {'net.core.somaxconn':
    ensure  => present,
    value   => '4092',
    comment => 'test',
  }
  sysctl {'net.ipv4.tcp_max_syn_backlog':
    ensure  => present,
    value   => '8192',
    comment => 'test',
  }
}
