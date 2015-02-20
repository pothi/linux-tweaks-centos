#!/bin/bash

# Install and setup an initiate docker
# Ref: http://wiki.centos.org/Cloud/Docker

# as root
if [[ $USER != "root" ]]; then
	echo "This script must be run as root"
	exit 1
fi

# bring in a new testing repo
echo '[virt7-testing]
name=virt7-testing
baseurl=http://cbs.centos.org/repos/virt7-testing/x86_64/os/
enabled=1
gpgcheck=0
includepkgs=docker*' > /etc/yum.repos.d/docker.repo

echo 'Installing docker... please be patient...'
yum install docker -yq

groupadd docker &> /dev/null

echo 'Enabling docker'
systemctl enable docker
systemctl stop docker &> /dev/null
systemctl start docker

# followup
# add docker user and then add it to docker group
