class ssmtp::disable {
  package { ssmtp:
    ensure => absent,
  }
}
