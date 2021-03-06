# == Class: tungsten::prereq::hostname See README.md for documentation.
#
# Copyright (C) 2014 Continuent, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.  You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

class tungsten::prereq::hostname(
	$nodeHostName									= $fqdn,
) {
	file { "continuent-hostname":
        path => '/etc/hostname',
		ensure => present,
		owner => root,
		group => root,
		mode => 644,
		content => "$nodeHostName\n",
	}

	exec { "set-hostname":
		command => "/bin/hostname -F /etc/hostname",
		unless => "/usr/bin/test `hostname` = `/bin/cat /etc/hostname`",
		require => File["continuent-hostname"],
	}

	if ($operatingsystem =~ /(?i:centos|redhat|oel|OracleLinux|amazon)/) {
		exec { "set-network-hostname":
			command => "/bin/sed -i -e \"s/HOSTNAME=.*/HOSTNAME=$nodeHostName/\" /etc/sysconfig/network",
			unless => "/usr/bin/test `grep HOSTNAME /etc/sysconfig/network` = 'HOSTNAME=$nodeHostName'",
		}
	}
}
