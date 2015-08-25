# Vagrant Mule Mysql and API Umbrella

This a vagrant configuration for a CentOS 6.5 machine with API Umbrella, Mule CE 3.5 Standalone, MySQL Server 5.1, JRE 1.7 and Maven 3.3

In order to install all components you need to download the following packages under the directory `puppet/resources/`
```
wget https://developer.nrel.gov/downloads/api-umbrella/el/6/api-umbrella-0.8.0-1.el6.x86_64.rpm

wget https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/3.5.0/mule-standalone-3.5.0.tar.gz

wget https://raw.githubusercontent.com/jbetanzos/mulesoft-sf-twitter-mysql-integration/master/src/main/resources/Company20150731.sql
```

Look for the `api-umbrella.yml` file under `puppet/config/api-umbrella.yml`. Replace the value `your.email@example.com` for you own mail in order to log into the API Umbrella.

API Umbrella log-in is supported by different strategies. Since this is a local installation you will need to use Mozilla Persona.

## Mule Project Configuration
In order to test the configuration you can download the [ASI-Demo](https://www.dropbox.com/s/3h9c01zhyqfcaog/asi-demo.zip?dl=0) application and place the zip file in `mule/apps/`.

The `mule/apps` directory is used on this configuration because is linked to the vagrant installation of mule. Each Mule Application that you put in this directory will be deployed. 

In order for you to check if the deployment was successful check the mule logs
```
$ vagrant ssh -c “tail -f /opt/mule/logs/mule.log”
```

In your host machine open a browser or use Postman to send the following request
```
http://33.33.33.93:8081/API/mailing_list.html?type=list&input=%3CDATASET%3E%20%20%3CSITE_ID%3E2010001045%3C%2FSITE_ID%3E%20%20%3CMLID%3E292401%3C%2FMLID%3E%20%20%3CDATA%20type%3D%22extra%22%20id%3D%22password%22%3EUus892jsoO%3C%2FDATA%3E%20%20%3CDATA%20type%3D%22list-id%22%3E11589%3C%2FDATA%3E%3C%2FDATASET%3E
```

*NOTICE*: Mule Server needs to be started manually every time you 
restart the box.

Check if Mule is running with `vagrant ssh -c “sudo /etc/init.d/status”` if it is not running then:
```
$ vagrant ssh -c ‘sudo /etc/init.d/mule start’
```

## API Umbrella configuration
API Umbrella will be installed after you `vagrant up` your box. Make sure API Umbrella is running with `vagrant ssh -c “sudo /etc/init.d/api-umbrella status”` if not then execute `vagrant ssh -c “sudo /etc/init.d/api-umbrella start”`

### Monitor an API
Login into API Umbrella for this configuration use `https://33.33.33.93/admin`

Go to *Configuration > API Backends*, and apply the following configuration:
```
Name: demo
Banckend: http
Server: http://33.33.33.93:8081
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

Open a browser and test the API manager by calling more than 5 times the service `https://33.33.33.93/API/mailing_list.html?type=list&input=%3CDATASET%3E%20%20%3CSITE_ID%3E2010001045%3C%2FSITE_ID%3E%20%20%3CMLID%3E292401%3C%2FMLID%3E%20%20%3CDATA%20type%3D%22extra%22%20id%3D%22password%22%3EUus892jsoO%3C%2FDATA%3E%20%20%3CDATA%20type%3D%22list-id%22%3E11589%3C%2FDATA%3E%3C%2FDATASET%3E` you will get a text like this:
```
<DATASET>
    <TYPE>success</TYPE>
    <RECORD>
        <DATA type=“state”>uploaded</DATA>
    </RECORD>
</DATASET>
```

## Important Considerations
Notice that CentOS works with iptables enable and this configuration is open to work with port 8081. If you need to change this port you will need to add a new firewall rule to open another port. If you want to use it for testing purposes you can stop the firewall with the following commands
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