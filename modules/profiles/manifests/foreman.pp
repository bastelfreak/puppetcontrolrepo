class profiles::foreman {
  class{'foreman':
    db_manage       => true,
  }

  # run async tasks
  # https://github.com/theforeman/foreman-tasks
  contain foreman::plugin::tasks

  # this allows us to run custom hooks
  # https://github.com/theforeman/foreman_hooks
  contain foreman::plugin::hooks

  # allow nodes to set their own env
  # but still be authoritative for all other nodes
  # https://github.com/joshuabaird/foreman_noenv
  foreman::plugin{'noenv':
    package => 'tfm-rubygem-foreman_noenv',
  }

  # assign a default host group
  # https://github.com/theforeman/foreman_default_hostgroup
  contain foreman::plugin::default_hostgroup

  # setup docker support in foreman
  contain foreman::plugin::docker

  foreman::plugin{'column_view':
    package =>  'tfm-rubygem-foreman_column_view',
  }

  # foreman puppetdb
  # should be done after foreman is installed
  # should reload httpd
  class{'foreman::plugin::puppetdb':
    address => "https://${facts['fqdn']}:8081/pdb/cmd/v1",
  }
}