class continuent_install::mysql::server (
) inherits continuent_install::mysql {
	include continuent_install::prereq
	
	if $masterPassword == 'secret' {
		warning 'The default master password is being used'
	}
	
	$serverId	= fqdn_rand(5000,$::continuent_install::prereq::nodeIpAddress)
	$sqlCheck	= "select * from mysql.user where user=''"
	$sqlExec		= "delete from mysql.user where user='';flush privileges;"
	
	if ($operatingsystem =~ /(?i:centos|redhat|oel|amazon)/) {
		Class["continuent_install::prereq"] ->
		package { 'mysql-server': 
			ensure => present, 
 			before => [Package[percona-release]]
		} ->
		package { 'mysql': 
			ensure => present,
		} ->
		anchor { "continuent_install::mysql::server::package": }
	} else {
		Class["continuent_install::prereq"] ->
		anchor { "continuent_install::mysql::server::package": }
	}
	
	
	Anchor["continuent_install::mysql::server::package"] ->
	file { "my.cnf":
		path		=> "/etc/my.cnf",
		owner	 => $serviceUser,
		group	 => root,
		mode		=> 644,
		content => template("continuent_install/my.erb"),
	} ->
	service { "continuent_install::mysql::server" :
		name => $serviceName,
		enable => true,
		ensure => running,
	} ->
	exec { "set-mysql-password":
		path => ["/bin", "/usr/bin"],
		command => "mysqladmin -uroot password $masterPassword",
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql -u root"]
	} ->
	file { "${::root_home}/.my.cnf":
	  content => template('continuent_install/my.cnf.pass.erb'),
	  owner   => root,
	  mode    => '0600',
	} ->
	exec { "remove-anon-users":
		onlyif	=> ["/usr/bin/test -f /usr/bin/mysql", "/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlCheck\"|wc -l"],
		command => "/usr/bin/mysql --defaults-file=${::root_home}/.my.cnf -Be \"$sqlExec\"",
	}	
}