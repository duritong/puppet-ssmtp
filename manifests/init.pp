# modules/ssmtp/manifests/init.pp - Basic ssmtp installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

$ssmtp_base_dir = "/var/lib/puppet/modules/ssmtp"
$admin_domain_dir = "${ssmtp_base_dir}/domains"
$admin_host_dir   = "${ssmtp_base_dir}/hosts"

modules_dir { [ "ssmtp", "ssmtp/domains", "ssmtp/hosts" ]: }

class ssmtp {
	$seedfile = "${ssmtp_base_dir}/ssmtp.seeds"
	config_file { $seedfile: content => template("ssmtp/ssmtp.seeds"), }

	package { ssmtp:
		ensure => installed,
		responsefile => $seedfile,
		require => File[$seedfile],
	}

	ssmtp::option {
		"mailhub": ensure => $smarthost;
		"rewriteDomain": ensure => $fqdn;
		"hostname": ensure => $fqdn;
	}

	exim4::relay_from { $ipaddress: }

	# This is a real alias file for exim to search for specific
	# destinations, TODO: replace the * by a correct list of senders
	@@file {
		"$admin_domain_dir/$fqdn":
			content => "root: $admin_mail\npostmaster: $admin_mail\ncron: $admin_mail\nlogcheck: $admin_mail\n",
	}

	# make exim4 and ssmtp classes conflict
	package { exim4: ensure => absent, }

	munin::plugin { [ "exim_mailqueue", "exim_mailstats" ]: ensure => absent }

	nameserver::check_dig2 { $fqdn:
		target_host => 'fw-schmidg.edv-bus.at',
		record_type => 'MX',
		expected_address => $smarthost,
	}

	define option ($ensure) {
		replace { "ssmtp_option_$name":
			file => "/etc/ssmtp/ssmtp.conf",
			pattern => "^$name=(?!$ensure).*",
			replacement => "$name=$ensure",
		}
	}

}


# designate a host as recipient for admin mails
# This also requires the 140_local_admin_router
# TODO: refactor exim4 configuration to here
class admin_mx {
	exim4::config_file {
		"main/02_puppet_admin_list":
			content => "domainlist admin_domains = dsearch;$admin_domain_dir\n";
	}

	#update_exim4_param { dc_relay_domains: ensure => "+admin_domains"; dc_relay_nets: ensure => "+admin_hosts"; }

	# TODO: restrict collected files here
	File <<||>>
}

