FROM centos:7
RUN yum update --assumeyes
RUN yum install --assumeyes https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
RUN yum install --assumeyes puppet puppetserver
RUN source /etc/profile.d/puppet-agent.sh
RUN /opt/puppetlabs/bin/puppet module install puppet-r10k
RUN /opt/puppetlabs/bin/puppet cert generate puppet.local --dns_alt_names=puppet.local,puppet,puppetdb,puppetdb.local
RUN /opt/puppetlabs/bin/puppet apply -e 'include r10k'
RUN sed -i 's#remote:.*#remote: https://github.com/bastelfreak/puppetcontrolrepo.git#' /etc/puppetlabs/r10k/r10k.yaml
RUN r10k deploy environment --puppetfile --verbose
