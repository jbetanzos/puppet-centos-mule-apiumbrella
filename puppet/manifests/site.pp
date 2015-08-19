Exec { path => "/bin:/usr/bin", }

class { 'java':
	package               => 'java-1.7.0-openjdk-devel',
	java_alternative      => 'jre-1.7.0-openjdk'
}

class { 'mysql::server':
	root_password => 'betanzos'
}

mysql::db { 'mysql-server':
	user => 'lyris',
	password => 'lyris',
	host => 'localhost',
	grant => ['ALL'],
	sql => '/vagrant/puppet/resources/Company20150731.sql'
}

include 'maven'

exec { untar-mule:
	command => "tar xvzf /vagrant/puppet/resources/mule-standalone-3.5.0.tar.gz && ln -s /opt/mule-standalone-3.5.0 /opt/mule",
	cwd => "/opt",
	environment => 'MULE_HOME=/opt/mule',
	creates => "/opt/mule-standalone-3.5.0"
}

service { "mule":
	ensure => running,
	start => "/opt/mule/bin/mule -M-Dmule.mmc.bind.port=7773 -Wwrapper.daemonize=TRUE",
	stop => "/opt/mule/bin/mule stop",
	status => "/opt/mule/bin/mule status",
	pattern => "/opt/mule/bin/mule -M-Dmule.mmc.bind.port=7773 -Wwrapper.daemonize=TRUE"
}

package { 'api-umbrella':
	ensure => installed,
	provider => 'rpm', 
	source => '/vagrant/puppet/resources/api-umbrella-0.8.0-1.el6.x86_64.rpm'
}

firewall { '80 forward to LYRIS_CHAIN':
  chain   => 'INPUT',
  jump    => 'LYRIS80_CHAIN',
}
# The namevar here is in the format chain_name:table:protocol
firewallchain { 'LYRIS80_CHAIN:filter:IPv4':
  ensure  => present,
}
firewall { '80 lyris rule':
  chain   => 'LYRIS80_CHAIN',
  action  => 'accept',
  proto   => 'tcp',
  dport   => 80,
}

firewall { '443 forward to LYRIS_CHAIN':
  chain   => 'INPUT',
  jump    => 'LYRIS443_CHAIN',
}
# The namevar here is in the format chain_name:table:protocol
firewallchain { 'LYRIS443_CHAIN:filter:IPv4':
  ensure  => present,
}
firewall { '443 lyris rule':
  chain   => 'LYRIS443_CHAIN',
  action  => 'accept',
  proto   => 'tcp',
  dport   => 443,
}

# Mule CE 3.5 Port
firewall { '7773 forward to MULE_CHAIN':
  chain   => 'INPUT',
  jump    => 'LYRIS7773_CHAIN',
}
firewallchain { 'LYRIS7773_CHAIN:filter:IPv4':
  ensure  => present,
}
firewall { '7773 lyris rule':
  chain   => 'LYRIS7773_CHAIN',
  action  => 'accept',
  proto   => 'tcp',
  dport   => 7773,
}

# MySQL Server Port
firewall { '3306 forward to MULE_CHAIN':
  chain   => 'INPUT',
  jump    => 'LYRIS3306_CHAIN',
}
firewallchain { 'LYRIS3306_CHAIN:filter:IPv4':
  ensure  => present,
}
firewall { '3306 lyris rule':
  chain   => 'LYRIS3306_CHAIN',
  action  => 'accept',
  proto   => 'tcp',
  dport   => 3306,
}