# Vagrant Mule Mysql and API Umbrella

This a vagrant configuration for a CentOS 6.5 machine with API Umbrella, Mule CE 3.5 Standalone, MySQL Server 5.1, JRE 1.8 and Maven 3.3

In order to install all components you need to download the following packages under the directory `puppet/resources/`
```
wget https://developer.nrel.gov/downloads/api-umbrella/el/6/api-umbrella-0.8.0-1.el6.x86_64.rpm

wget https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/3.5.0/mule-standalone-3.5.0.tar.gz

wget https://raw.githubusercontent.com/jbetanzos/mulesoft-sf-twitter-mysql-integration/master/src/main/resources/Company20150731.sql
```

## Mule Project Configuration
The SQL file contains a database necessary to run the [AppSFTW35](https://github.com/jbetanzos/mulesoft-sf-twitter-mysql-integration) Mule Application. In case you don’t want the database or you want to restore a custom file go to `puppet/manifest/site.pp` you can edit lines 12 to 18
```
mysql::db { ‘mysql-server’:
	user => ‘lyris’,
	password => ‘lyris’,
	host => ‘localhost’,
	grant => [‘ALL’],
	sql => ‘/vagrant/puppet/resources/Company20150731.sql’
}
```
In order to test the configuration you can clone the application and open it with Anypoint Studio. After you configure the application properly you can export it and place the file in `mule/apps/`.

The `mule/apps` directory is used on this configuration because is linked to the vagrant installation of mule. Each Mule Application that you put in this directory will be deployed. 

In order for you to check if the deployment was successful check the mule logs entering the vagrant box with `vagrant ssh` then
```
$ tail -f /opt/mule/logs/mule.log
```

In your host machine open a browser or use Postman to send a GET request to the following URI
```
http://33.33.33.93:8083/api/reports/totalcases
```
This request will connect to SalesForce to query a Cases report

*NOTICE*: Mule Server needs to be started manually every time you 
restart the box.

## API Umbrella configuration
API Umbrella will be installed after you `vagrant up` your box. Additional configuration is required.

- `vagrant ssh` you box and edit the `api-umbrella.yml` file
```
$ sudo vi /etc/api-umbrella/api-umbrella.yml
```
- In the config file, define an e-mail address for your first admin account:
```
web:
  admin:
    initial_superusers:
      - your.email@example.com
```
Make sure this lines are uncommented (drop #), exit your box and retart your box with `vagrant reload`

After your box restarted, in your host machine open a browser and enter to `https://33.33.33.93/admin`. Notice that since this is a local installation you will be able to log into API Umbrella using Persona, using a FireFox browser. Use the same email address you update in the `api-umbrella.yml`

### Monitor an API
Login into API Umbrella for this configuration use `https://33.33.33.93/admin`

Go to *Configuration > API Backends*, and apply the following configuration:
```
Name: demo
Banckend: http
Server: http://33.33.33.93:8083
Frontend Host: 33.33.33.93
Backend Host: 33.33.33.93
Frontend Prefix: /
Backend Prefix: /

#### Global Request Settings
API Key Checks: Disable - API keys are optional
Rate limit: Custom rate limits
Duration: 1 minute
Limit by: IP Address
Limit: 5 request
Primary [x]
Anonymous Rate Limit Behaviour: IP Only
Authenticated Rate Limit Behaviour: All Limits
```
Above configurations will monitor the API project AppSFTW35 by allowing 5 calls per minute by IP. In order to this changes take affect save the configuration and then go to *Configuration > Publish Changes*, check the demo configuration and *Publish*

Open a browser and test the API manager by calling more than 5 times the service `https://33.33.33.93/api/reports/totalcases` you will get a text like this:
```
{
  “error”: {
    “code”: “OVER_RATE_LIMIT”,
    “message”: “You have exceeded your rate limit. Try again later or contact us at https://33.33.33.93/contact for assistance”
  }
}
```

## Important Considerations
Notice that CentOS works with iptables enable and this configuration is open to work with port 8083. If you need to change this port you will need to add a new firewall rule to open another port. If you want to use it for testing purposes you can stop the firewall with the following commands
```
sudo /etc/init.d/iptables save
sudo /etc/init.d/iptables stop
sudo chkconfig iptables off
```

## Puppet Necessary Modules

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
You can find this installation in [puppet/shell/init.sh](https://raw.githubusercontent.com/jbetanzos/puppet-centos-mule-apiumbrella/master/puppet/shell/init.sh)