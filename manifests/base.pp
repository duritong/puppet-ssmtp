class ssmtp::base {
  package { ssmtp:
    ensure => present,
  }

  file {'/etc/ssmtp/ssmtp.conf':
    content => template('ssmtp/default.erb'),
    require => Package[ssmtp],
    owner => root, group => 0, mode => 644;
  }
}
