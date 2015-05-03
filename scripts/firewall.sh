#!/bin/bash

# Sets up firewall and open common ports (aka services)
# this isn't needed on certain hosts such as AWS, GCE
# where the hosts have firewall on top of the OS

echo

# make sure firewall isn't running
# if the following command shows an error message
# we are good to go
firewall-cmd --list-all
# error message
# FirewallD is not running
if [ "$?" == "0" ]; then
	echo 'Firewall seems running. So, exiting prematurely'
	echo
fi

# as root
if [[ $USER != "root" ]]; then
	echo "This script must be run as root"
	exit 1
fi

# enable and start firewall daemon
systemctl enable firewalld
systemctl start firewalld

echo 'Adding port 80'
firewall-cmd --add-service=http
firewall-cmd --permanent --add-service=http

echo 'Adding port 443'
firewall-cmd --add-service=https
firewall-cmd --permanent --add-service=https

firewall-cmd --list-all

systemctl restart fail2ban
# http://www.fail2ban.org/wiki/index.php/Commands
# check status
# fail2ban-client status sshd
# unban IP
# fail2ban-client set sshd unbanip 45.56.116.200

echo 'All done. If you see any error message, contact pothi'
echo
