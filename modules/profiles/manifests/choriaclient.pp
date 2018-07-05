# this class configures a choria client
# you want to put this on a single node, maybe your puppetserver
class profiles::choriaclient {
  # increase sysctl settings because the broker can be hit by a lot of network traffic
  # suggested in the official docs at https://choria.io/docs/deployment/broker/#large-deploys
  sysctl {'net.core.somaxconn':
    ensure  => present,
    value   => '4092',
    comment => 'test',
    before  => Class['Choria::Broker'],
  }
  sysctl {'net.ipv4.tcp_max_syn_backlog':
    ensure  => present,
    value   => '8192',
    comment => 'test',
    before  => Class['Choria::Broker'],
  }

  # also deploy a broker
  class{'choria::broker':
    network_broker => true
  }
}
