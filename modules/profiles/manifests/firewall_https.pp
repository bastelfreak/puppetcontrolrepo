class profiles::firewall_https {
  ferm::rule{'allow_https':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '443',
  }
}
