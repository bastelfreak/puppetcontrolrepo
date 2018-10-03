# this is supposed to be used once, to build a "single node cluster"
class profiles::consulserver {
  if $facts['os']['family'] == 'RedHat' {
    ensure_packages(['unzip'])
  }
  class{'consul':
    version        => '1.2.3',
    pretty_config  => true,
    enable_beta_ui => true,
    config_hash    => {
      'bind_addr'            => $facts['networking']['ip6'],
      'bootstrap_expect'     => 1,
      'data_dir'             => '/opt/consul',
      'datacenter'           => 'NBG',
      'log_level'            => 'INFO',
      'node_name'            => $facts['fqdn'],
      'server'               => true,
      'disable_update_check' => true,
      'enable_script_checks' => true,
      'ui'                   => true,
    },
    require        => Package['unzip'],
  }
}
