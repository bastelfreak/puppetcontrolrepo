class profiles::choriaserver {
  if($facts['os']['name'] == 'CentOS') {
    package{'libffi-devel':
      ensure => 'present',
    }
  }
  include mcollective
}
