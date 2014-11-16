# manage ssmtp stuff
# Copyright (C) 2007 admin@immerda.ch
#
class ssmtp(
  $mailhub            = "mail.${::domain}",
  $rewrite_domain     = $::fqdn,
  $hostname           = $::fqdn,
  $from_line_override = 'YES',
  $use_ssl            = 'YES',
  $manage_shorewall   = false
) {

  # set option file
  $tls_ca_file = $::operatingsystem ? {
    CentOS  => '/etc/pki/tls/certs/ca-bundle.crt',
    default => undef,
  }

  case $::operatingsystem {
    centos: { include ssmtp::centos }
    gentoo: { include ssmtp::gentoo }
    default: { include ssmtp::base }
  }
  if $manage_shorewall {
    include shorewall::rules::out::smtp
    include shorewall::rules::smtp::disable
    include shorewall::rules::smtps::disable
  }
}
