class profiles::basics {
  # epel is needed by foreman and ferm
  # foreman could provide epel for us, but we need to apply the basiscs class before :(
  $osreleasemajor = $facts['os']['release']['major']
  $epel_gpgkey = $osreleasemajor ? {
    '7'     => 'https://fedoraproject.org/static/352C64E5.txt',
    default => 'https://fedoraproject.org/static/0608B895.txt',
  }
  yumrepo { 'epel':
    descr      => "Extra Packages for Enterprise Linux ${osreleasemajor} - \$basearch",
    mirrorlist => "https://mirrors.fedoraproject.org/metalink?repo=epel-${osreleasemajor}&arch=\$basearch",
    baseurl    => "http://download.fedoraproject.org/pub/epel/${osreleasemajor}/\$basearch",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => $epel_gpgkey,
  }
  ->class{'ferm':
    manage_service    => true,
    manage_configfile => true,
  }

  ferm::rule{'allow_ssh':
    chain  => 'INPUT',
    policy => 'ACCEPT',
    proto  => 'tcp',
    dport  => '22',
  }

  # do a pluginsync in agentless setup
  # lint:ignore:puppet_url_without_modules
  file { $::settings::libdir:
    ensure  => directory,
    source  => 'puppet:///plugins',
    recurse => true,
    purge   => true,
    backup  => false,
    noop    => false,
  }
  # lint:endignore

  # install mandatory packages
  # unzip is needed for the archive resource
  ensure_packages(['unzip'])

  # collect the /etc/hosts entries from our puppetserver
  # Just for the assumption that we've got multiple nodes
  # This is DNS like before it was DNS!
  # We don't need to import it on our puppetserver
  if ($facts['fqdn'] != 'puppet.local') {
    File_line <<| tag == 'puppetserver' |>>
  }

  # only allow ssh access via key
  class{'ssh':
    server_options       => {
      'PasswordAuthentication' => 'no',
      'PermitRootLogin'        => 'yes',
    },
  }
}
