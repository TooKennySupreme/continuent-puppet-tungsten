# == Class: tungsten See README.md for documentation.
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

class tungsten (
		$nodeHostName										= $fqdn,
		$installMysqlj									= true,
      $mysqljLocation               = false,
		$installJava										= true,
		$installNTP											= $tungsten::params::installNTP,
		$disableFirewall							  = true,

		$disableSELinux                 = true,

		# This may be set to 'nightly', 'stable' or 'true
		# If set to 'true', the stable repository will be used
		$replicatorRepo									= false,

		#Setting this to true should only be used to support
		#testing as it's not secure unless you specify a custom private key
		$installSSHKeys									= false,
		  $sshPublicKey                 = $tungsten::params::defaultSSHPublicKey,
  	  $sshPrivateCert               = $tungsten::params::defaultSSHPrivateCert,

		$installMysql										= false,
      $overrideOptionsMysqld         = {},
      $overrideOptionsClient         = {},
      $overrideOptionsMysqldSafe     = {},
			#Which Repo to install percona,mysql or mariadb
			$mySQLBuild									   = 'percona',
			#Version to install based on repo 5.5, 5.6, 5.7, 10.0
			$mySQLVersion									 = '5.5',
			#Set the my.cnf autoinc and autoinc offset based on clusterData
			$mySQLSetAutoIncrement				= false,
			$installXtrabackup						 = false,

		# Set this to true if you are not passing $clusterData
	  # and want the /etc/tungsten/defaults.tungsten.ini file
	  # to be created
	  $writeTungstenDefaults                  = false,

		# Set this to 'true' or the path of a tungsten-replicator package
		# If set to 'true', the 'tungsten-replicator' will be installed from
		# configured repositories.
		$installReplicatorSoftware			= false,
			$replicationUser							= tungsten,
			$replicationPassword					= secret,
			$replicationLogDirectory		= false,

		# Set this to 'true' or the path of a continuent-tungsten package
		# If set to 'true', the 'continuent-tungsten' will be installed from
		# configured repositories.
		$installClusterSoftware					= false,
			$clusterData									= false,
			$appUser											= app_user,
			$appPassword									= secret,
			$applicationPort							= 3306,

		# Run the `tungsten_provision_slave` script after installing Tungsten
		$provisionNode									= false,
			$provisionDonor								= "autodetect",

    #If this is set to true no setting of hostname will be done
    $skipHostConfig                 = false
) inherits tungsten::params {


  class { 'tungsten::prereq::tungstenselinux': disableSELinux=>$disableSELinux }

  class { "tungsten::tungstenmysql":
      overrideOptionsMysqld 		=> $overrideOptionsMysqld,
      overrideOptionsClient 		=> $overrideOptionsClient,
      overrideOptionsMysqldSafe => $overrideOptionsMysqldSafe,
      installMysql 							=> $installMysql,
			mySQLBuild				 				=> $mySQLBuild,
			mySQLVersion				   		=> $mySQLVersion,
			clusterData 							=> $clusterData,
			mySQLSetAutoIncrement							=> $mySQLSetAutoIncrement,
			installXtrabackup				  => $installXtrabackup
	}  ->
  class{ "tungsten::prereq":
    nodeHostName                => $nodeHostName,
    replicatorRepo              => $replicatorRepo,
    installMysqlj               => $installMysqlj,
    mysqljLocation              => $mysqljLocation,
    installSSHKeys              => $installSSHKeys,
    sshPublicKey                => $sshPublicKey,
    sshPrivateCert              => $sshPrivateCert,
    installJava                 => $installJava,
    installNTP                  => $installNTP,
    disableFirewall             => $disableFirewall,
    skipHostConfig              => $skipHostConfig
  } ->
	class { "tungsten::tungsten":
		writeTungstenDefaults				=> $writeTungstenDefaults,
		installReplicatorSoftware 	=> $installReplicatorSoftware,
			repUser 									=> $replicationUser,
			repPassword 							=> $replicationPassword,
			replicationLogDirectory						=> $replicationLogDirectory,
		installClusterSoftware 			=> $installClusterSoftware,
			clusterData 							=> $clusterData,
			appUser 									=> $appUser,
			appPassword 							=> $appPassword,
			applicationPort 					=> $applicationPort,
		provision 									=> $provisionNode,
			provisionDonor 						=> $provisionDonor,
	}
}
