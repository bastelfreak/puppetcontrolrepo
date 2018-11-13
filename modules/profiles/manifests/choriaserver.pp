class profiles::choriaserver {
  if($facts['os']['name'] == 'CentOS') {
    package{'libffi-devel':
      ensure => 'present',
      before => Class['mcollective'],
    }
  }
  # we only add choria/choria to metadata.json
  # it pulls in choria/mcollective and choria/mcollective_choria
  # mcollective pulls in gems that require make
  # mcollective pulls in gems that require gcc
  ensure_packages(['gcc', 'make'], { before => Class['mcollective']})
  include mcollective
  include choria
}
