# a profile to configure gitlab on CentOS 7
class profiles::gitlab {
  include gitlab

  include ferm

  ferm::rule{'allow_http_https':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '(80 443)',
  }
}
