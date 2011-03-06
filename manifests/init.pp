# modules/ssmtp/manifests/init.pp - manage ssmtp stuff
# Copyright (C) 2007 admin@immerda.ch
#

class ssmtp {
  case $operatingsystem {
    centos: { include ssmtp::centos }
    gentoo: { include ssmtp::gentoo }
    default: { include ssmtp::base }
  }
  if $use_shorewall {
    include shorewall::rules::out::smtp
    include shorewall::rules::smtp::disable
    include shorewall::rules::smtps::disable
  }
}
