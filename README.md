# Puppet All In One Stack on CentOS 7

This guide will provision an all in one stack on CentOS 7. It is based on the
new [Hetzner Online](https://www.hetzner.de/cloud) cloud instances.

* [Setup](#setup)
    * [Basics Profile](#basics-profile)
    * [GitLab Profile](#gitlab-profile)
    * [Foreman Profile](#foreman-profile)
    * [Consul Server Profile](#consulserver-profile)
* [Provisioning](#provisioning)
    * [Setup the instance](#setup-the-instance)
    * [Provision script](#provision-script)
* [Constraints](#constraints)
* [Related issues and pull requests](#related-issues-and-pull-requests)
* [Further documentation](#further-documentation)

---

## Setup

We provide profiles for the following services:

* [Basics](modules/profiles/manifests/basics.pp)
* [Puppetserver](modules/profiles/manifests/puppetserver.pp)
    * [Foreman Proxy](modules/profiles/manifests/foremanproxy.pp)
* [PuppetDB](modules/profiles/manifests/puppetdb.pp)
* [Foreman](modules/profiles/manifests/foreman.pp)
* [Choria Server](modules/profiles/manifests/choriaserver.pp)
* [Choria Client](modukes/profiles/manifests/choriaclient.pp)
* [GitLab](modules/profiles/manifestsgitlab.pp)


### `basics` Profile

This profile handles common utilities that are shared across every potential
node. Currently this is the firewall handling. The `ferm` class is included
with needed parameters. They are set in hiera as well, but that is a bit tricky
if you run `puppet apply`. All other profiles, that require open ports, include
the ferm class as well. You need to ensure to evaluate the `basics` class
before any other class.

ToDo: Implement handling of common packages

### `gitlab` Profile

Everybody wants a central collaboration platform, with chat software, git
hosting, issue handling and CI/CD stack, right? GitLab provides all of that!

### `foreman` Profile

Installs [Foreman](https://theforeman.org/) with postgresql database. The
password for the admin account can be retrieved with:

```sh
awk '{print $2; exit}' /opt/puppetlabs/puppet/cache/foreman_cache_data/admin_password
```

Just because we can: We deploy a [Memcached](https://memcached.org/) instance
as a cache for our Foreman.

### `consulserver` Profile

Consul provides DNS based loadbalancing for our Puppetserver and also acts as
service discovery for Prometheus.

## Provisioning

As mentioned in the introduction, the goal of this repo is to setup a working
Puppet 6 stack. All profiles should have individual acceptance tests, but this
also has to work in a reald world scenario. I chose Hetzner as a cloud provider
because their setup is cheap and works and has a proper API. The instructions
in this README.md will create a single box with everything you can dream off,
but the profiles are designed in a way that they are flexible. You can rip out
single parts like PuppetDB or the PostgreSQL database to single servers. The
README.md might get extended with that data in the future.

### Setup the instance

Basically two setups, upload an ssh key and afterwards create a server:

```bash
hcloud ssh-key create --public-key-from-file=${HOME}/.ssh/id_ed25519.pub --name puppetkey
hcloud server create --ssh-key puppetkey --image centos-7 --type=cx21 --name puppet.local
```

You can delete unneeded instances with:
```bash
hcloud server delete puppet.local
```

### Provision script

First of we need to fix selinux:

```bash
# /etc/sysconfig/selinux is the wrong file
sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
touch /.autorelabel
sync
reboot
```

Afterwards we start the real setup:

```bash
yum update --assumeyes
yum install --assumeyes https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum install --assumeyes puppet puppetserver
source /etc/profile.d/puppet-agent.sh
puppet module install puppet-r10k
puppet cert generate puppet.local --dns_alt_names=puppet.local,puppet,puppetdb,puppetdb.local
puppet apply -e 'include r10k'
sed -i 's#remote:.*#remote: https://github.com/bastelfreak/puppetcontrolrepo.git#' /etc/puppetlabs/r10k/r10k.yaml
r10k deploy environment production --puppetfile --verbose
puppet apply -e 'include roles::puppetserver'
puppet agent -t --server puppet.local
```

## Constraints

* The FQDN of the puppserver node should be `puppet.local`. The certificate is
valid for `puppet` and `puppet.local`. We create an entry in `/etc/hosts` for
each client, so it can reach the server under that FQDN and we don't need to
deal with DNS.
* PostgreSQL 10 is [not yet supported](https://tickets.puppetlabs.com/browse/PDB-3857) properly by PuppetDB
* Many of the component module we depend on don't support/test on Puppet 6 yet

## Related issues and pull requests

During the work on this project we run into several issues. They are documented below

* https://github.com/puppetlabs/puppetlabs-puppetdb/pull/251
* https://github.com/puppetlabs/puppetlabs-apt/pull/822
* https://github.com/theforeman/puppet-puppet/pull/600
* https://github.com/theforeman/puppet-foreman/issues/649
* https://github.com/theforeman/puppet-puppet/pull/647
* https://github.com/voxpupuli/puppet-make/pull/29
* https://github.com/choria-io/mcollective-choria/pull/514
* https://github.com/choria-io/puppet-mcollective/pull/184
* https://github.com/joshuabaird/foreman_noenv/issues/19
* https://github.com/teemow/prometheus-borg-exporter/pull/6
* https://github.com/puppetlabs/puppetlabs-gcc/pull/17
* https://tickets.puppetlabs.com/browse/MODULES-7317
* https://tickets.puppetlabs.com/browse/MODULES-4124
* https://tickets.puppetlabs.com/browse/MODULES-4266
* https://github.com/camptocamp/puppetfile-updater/issues/7
* https://github.com/saz/puppet-ssh/pull/206
* https://github.com/saz/puppet-ssh/issues/250
* https://github.com/choria-io/puppet-choria/pull/72
* https://github.com/choria-io/puppet-choria/pull/74
* https://github.com/choria-io/puppet-choria/pull/95
* https://github.com/choria-io/puppet-mcollective/pull/198
* https://github.com/voxpupuli/puppet-r10k/pull/438
* https://github.com/voxpupuli/puppet-r10k/pull/439
* https://github.com/voxpupuli/puppet-r10k/pull/440
* https://community.theforeman.org/t/1-20-planning/10432
* https://github.com/saz/puppet-ssh/pull/256
* https://github.com/saz/puppet-ssh/pull/257
* https://github.com/saz/puppet-memcached/pull/101
* https://tickets.puppetlabs.com/browse/BKR-1493
* https://tickets.puppetlabs.com/browse/PDB-3857
* https://tickets.puppetlabs.com/browse/MODULES-8089
* https://github.com/camptocamp/puppetfile-updater/pull/17

## ToDo

* disable password authentication via ssh
* connect exporter <-> consul <-> prometheus -> grafana
* deploy katello
* Do we want a CI pipeline?
* Deploy puppet\_webhook
* deploy lldpd?
* check why choria server isn't deployed properly

## Further documentation

This is a collection of good links that you should check out if you are
interested in more details and background information about the used tools
within this stack

* [choria.io documentation](https://choria.io/docs)
* [Using hiera in rspec-puppet](https://github.com/rodjek/rspec-puppet#enabling-hiera-lookups)
* [Setup Puppet within beaker environments](https://github.com/puppetlabs/beaker-puppet_install_helper#beaker-puppet_install_helper)
* [Setup modules within beaker environments](https://github.com/puppetlabs/beaker-module_install_helper#beaker-module_install_helper)
* [Using the environment cache in Puppetserver](https://puppet.com/docs/puppetserver/6.0/admin-api/v1/environment-cache.html)
* [Properly purging the env cache](https://www.example42.com/2017/03/27/environment_caching/)

## Acceptance tests

The goal is to have acceptance tests for all profiles. The following are known to work:

```sh
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1804-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/node_exporter_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1604-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/node_exporter_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1804-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/node_exporter_spec.rb

PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=centos7-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=debian9-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1804-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1604-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet6 BEAKER_debug=true BEAKER_setfile=ubuntu1604-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet6 BEAKER_debug=true BEAKER_setfile=ubuntu1804-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet6 BEAKER_debug=true BEAKER_setfile=debian9-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet6 BEAKER_debug=true BEAKER_setfile=centos7-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/consulserver_spec.rb

PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=centos7-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaclient_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=debian9-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaclient_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1604-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaclient_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1804-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaclient_spec.rb

PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=centos7-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1804-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=ubuntu1604-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaserver_spec.rb
PUPPET_INSTALL_TYPE=agent BEAKER_IS_PE=no BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_debug=true BEAKER_setfile=debian9-64{hypervisor=docker\,hostname=puppet.local} BEAKER_destroy=yes bundle exec rspec spec/acceptance/choriaserver_spec.rb
```

### Limitations

* node\_exporter profile on Puppet 6 fails because it generates TLS certificates which is currently Puppet 5 specific
* node\_exporter profiles on Debian 9 fails because of [recent gpg changes](https://github.com/puppetlabs/puppetlabs-apt/pull/822) that are not compatible to puppetlabs/apt 6.1.1

## Docker

You can also deploy the whole stack with docker. First you need to build the image:

```
docker build --tag puppetfoo:0.3.0 .
```

Then you can run it:

```
docker run -it --hostname puppet.local puppetfoo:0.3.0
```
