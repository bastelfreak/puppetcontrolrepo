class profiles::basics {
  class{'ferm':
    manage_service    => true,
    manage_configfile => true,
  }

  ferm::rule{'allow_ssh':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '22',
  }
}
