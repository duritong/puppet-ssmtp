class ssmtp::base {
  include sendmail::disable
  include exim::disable

  package { ssmtp:
    ensure => present,
  }

  case $mailhub {
    '': { fail("no \$mailhub defined for ${fqdn}") }
  }

  $ssmtp_uses_ssl_real = $ssmtp_uses_ssl ? {
    '' => 'YES',
    default => $ssmtp_uses_ssl
  }

  $ssmtp_hostname_real = $ssmtp_hostname ? {
    '' => $fqdn,
    default => $ssmtp_hostname
  }

  $ssmtp_rewrite_domain_real = $ssmtp_rewrite_domain ? {
    '' => $fqdn,
    default => $ssmtp_rewrite_domain
  }

  $ssmtp_from_line_override_real = $ssmtp_from_line_override ? {
    '' => 'YES',
    default => $ssmtp_from_line_override
  }

  file { ssmtp_config:
    path => '/etc/ssmtp/ssmtp.conf',
    content => template('ssmtp/default.erb'),
    require => Package[ssmtp],
    owner => root, group => 0, mode => 644;
  }
}
