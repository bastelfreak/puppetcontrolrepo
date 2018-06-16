# Puppet All In One Stack on CentOS 7

This guide will provision an all in one stack on CentOS 7. It is based on the
new [Hetzner Online](https://www.hetzner.de/cloud) cloud instances.

## Provision script

First of we need to fix selinux:

```bash
# /etc/sysconfig/selinux is the wrong file
sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
touch /.autorelabel
reboot
```

Afterwards we start the real setup:

```bash
yum update --assumeyes
yum install --assumeyes https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum install --assumeyes puppet puppetserver
source /etc/profile.d/puppet-agent.sh
puppet module install puppet-r10k
sed -i 's#remote:.*#remote: https://github.com/bastelfreak/puppetcontrolrepo.git#' /etc/puppetlabs/r10k/r10k.yaml
r10k deploy environment --puppetfile --verbose
```
