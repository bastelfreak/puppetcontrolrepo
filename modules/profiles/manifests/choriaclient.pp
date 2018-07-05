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

  # broker needs to be accessible on port 4222 from all choria-server instances
  # 4223 needs to be accassible from each broker to each other broker, we only run one
  include ferm
  ferm::rule{'allow_choria_broker_access':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '4222',
  }
}
