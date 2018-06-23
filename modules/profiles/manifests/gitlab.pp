# a profile to configure gitlab on CentOS 7
class profiles::gitlab {
  include gitlab

  include ferm

  include profiles::firewall_http
  include profiles::firewall_https
}
