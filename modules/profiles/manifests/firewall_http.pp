class profiles::firewall_http {
  ferm::rule{'allow_http':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '80',
  }
}
