# modules/ssmtp/manifests/init.pp - manage ssmtp stuff
# Copyright (C) 2007 admin@immerda.ch
#

#modules_dir { "ssmtp": }

class ssmtp {
case $operatingsystem {
                centos: { include centos_repos }
        }

        package { ssmtp:
                name => $operatingsystem ? {
                        centos => 'ssmtp',
                        default => 'ssmtp',
                },
                category => $operatingsystem ? {
                        gentoo => 'mail-mta',
                        default => '',
                },
                ensure => present,
        }

        #set default mailhub if not yet one is set
        $mailhub_real = $mailhub ? {
           '' => 'mail.glei.ch',
           default => $mailhub
        }
        $ssmtp_uses_ssl_real = $ssmtp_uses_ssl ? {
           '' => 'YES',
           default => $ssmtp_uses_ssl
        }
        $mailhub_port_real = $ssmtp_uses_ssl_real ? {
           'YES' => ':465',
           default => ''
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
                owner => root,
                group => 0,
                ensure => file,
                mode => 644,
                require => Package[ssmtp],
                content => template('ssmtp/default.erb'),
        }
        package { sendmail:
                name => $operatingsystem ? {
                        centos => 'sendmail',
                        default => 'sendmail',
                },
                category => $operatingsystem ? {
                        gentoo => 'mail-mta',
                        default => '',
                },
                ensure => absent,
                require => Package[ssmtp],
        }
}

