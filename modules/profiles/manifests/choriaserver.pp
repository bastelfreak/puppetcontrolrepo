class profiles::choriaserver {
  if($facts['os']['name'] == 'CentOS') {
    package{'libffi-devel':
      ensure => 'present',
      before => Class['mcollective'],
    }
  }
  # we only add choria/choria to metadata.json
  # it pulls in choria/mcollective and choria/mcollective_choria
  include gcc
  include make
  include mcollective
  include choria

  # mcollective pulls in gems that require make
  Class['make'] -> Class['mcollective']

  # mcollective pulls in gems that require gcc
  Class['gcc'] -> Class['mcollective']
}
