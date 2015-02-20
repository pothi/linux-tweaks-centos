#!/bin/bash

# Sets up firewall and open common ports (aka services)

# as root
if [[ $USER != "root" ]]; then
	echo "This script must be run as root"
	exit 1
fi

# enable and start firewall daemon
systemctl enable firewalld
systemctl start firewalld

firewall-cmd --add-service=http
firewall-cmd --add-service=https
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
