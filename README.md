# Vagrant Mule Mysql and API Umbrella

This a vagrant configuration for a CentOS 6.5 machine with API Umbrella, Mule CE 3.5 Standalone, MySQL Server 5.1, JRE 1.7 and Maven 3.3

In order to install all components you need to download the following packages under the directory `puppet/resources/`
```
wget https://developer.nrel.gov/downloads/api-umbrella/el/6/api-umbrella-0.8.0-1.el6.x86_64.rpm

wget https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/3.5.0/mule-standalone-3.5.0.tar.gz

wget https://raw.githubusercontent.com/jbetanzos/mulesoft-sf-twitter-mysql-integration/master/src/main/resources/Company20150731.sql
```
In case you don’t need the database or you want to restore a custom file go to `puppet/manifest/site.pp` you can edit lines 12 to 18
```
mysql::db { ‘mysql-server’:
	user => ‘lyris’,
	password => ‘lyris’,
	host => ‘localhost’,
	grant => [‘ALL’],
	sql => ‘/vagrant/puppet/resources/Company20150731.sql’
}
```
The main components of the puppet configuration are based on the following modules.
```
#https://forge.puppetlabs.com/puppetlabs/mysql
puppet module install puppetlabs-mysql

#https://forge.puppetlabs.com/puppetlabs/java
puppet module install puppetlabs-java

#https://forge.puppetlabs.com/maestrodev/maven
puppet module install maestrodev-maven

#https://forge.puppetlabs.com/puppetlabs/firewall
puppet module install puppetlabs-firewall
```