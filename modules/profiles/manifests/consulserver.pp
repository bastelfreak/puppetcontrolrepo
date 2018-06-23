# this is supposed to be used once, to build a "single node cluster"
class profiles::consulserver {
  class{'consul':
    pretty_config  => true,
    enable_beta_ui => true,
    config_hash    => {
      'bootstrap_expect'     => 1,
      'data_dir'             => '/opt/consul',
      'datacenter'           => 'NBG',
      'log_level'            => 'INFO',
      'node_name'            => $facts['fqdn'],
      'server'               => true,
      'disable_update_check' => true,
      'enable_script_checks' => true,
      'ui'                   => true,
    }
  }
}
