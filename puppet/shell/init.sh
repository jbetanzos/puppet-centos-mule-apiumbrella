#!/bin/bash

 mkdir -p /etc/puppet/modules;

if [ ! -d /etc/puppet/modules/mysql ]; then
	puppet module install puppetlabs-mysql
fi

if [ ! -d /etc/puppet/modules/java ]; then
	puppet module install puppetlabs-java
fi

if [ ! -d /etc/puppet/modules/maven ]; then
	puppet module install maestrodev-maven
fi

if [ ! -d /etc/puppet/modules/firewall ]; then
	puppet module install puppetlabs-firewall
fi

if [ ! -f /etc/default/locale ]; then
	sudo echo "LANG=en_US.UTF-8" >> /etc/default/locale
	sudo echo "LANGUAGE=en_US" >> /etc/default/locale
	sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
fi