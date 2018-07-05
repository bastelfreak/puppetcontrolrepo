class profiles::choriaserver {
  if($facts['os']['name'] == 'CentOS') {
    package{'libffi-devel':
      ensure => 'present',
      before => Class['mcollective'],
    }
  }
  include gcc
  include make
  include mcollective
  include choria
  include nats

  # mcollective pulls in gems that require make
  Class['make'] -> Class['mcollective']

  # mcollective pulls in gems that require gcc
  Class['gcc'] -> Class['mcollective']

  # choria-server doesn't start properly without gnatsd running
  Class['nats'] -> Class['choria']
}
