#!/bin/bash

# Tweaks on bash, zsh, vim, tmux, etc on CentOS

# as root
# if [[ $USER != "root" ]]; then
	# echo "This script must be run as root"
	# exit 1
# fi

# TODO - change the default repo, if needed - mostly not needed on most hosts

# take a backup
mkdir -p /root/{backups,git,log,others,scripts,src,tmp} &> /dev/null

LOG_FILE=/root/log/linux-tweaks.log
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)

# take a backup
echo 'Taking an initial backup'
LT_DIRECTORY="/root/backups/etc-linux-tweaks-centos7-before-$(date +%F)"
if [ ! -d "$LT_DIRECTORY" ]; then
	cp -a /etc $LT_DIRECTORY
fi

# install dependencies
echo 'Updating the server'
yum update -y -q

echo 'Install prerequisites'
yum install -y epel-release

yum install -y zsh zsh-html \
	vim vim-enhanced \
	tmux \
	gcc \
	git subversion \
	python-pip \
	fail2ban-firewalld fail2ban-systemd \
	zip unzip \
	mlocate \
	logwatch postfix \
	yum-cron \
	bind-utils \
    redis-server

echo 'Install AWS CLI tools'
pip install awscli

# setup timezone
timedatectl set-timezone UTC
if [ $? != 0 ]; then
	echo 'Error setting up timezone'
fi

# get the source from Github
LTREPO=https://github.com/pothi/linux-tweaks-centos.git
echo 'Downloading Linux Tweaks from Github repo at '$LTREPO
rm -rf /root/ltweaks &> /dev/null
git clone --recursive $LTREPO ~/ltweaks

# Shell related configs
cp /root/ltweaks/tiny_* /etc/profile.d/

cat /root/ltweaks/zprofile >> /etc/zprofile
cat /root/ltweaks/zshrc >> /etc/zshrc

# Vim related configs
cp /root/ltweaks/vimrc.local /etc/vim/
cp -a /root/ltweaks/vim/* /usr/share/vim/vim74/

# Misc files
cat /root/ltweaks/tmux.conf > /etc/tmux.conf
cat /root/ltweaks/gitconfig > /etc/gitconfig

# Clean up
rm -rf /root/ltweaks/


# Common for all users
echo 'Setting up skel'
touch /etc/skel/.viminfo
touch /etc/skel/.zshrc
if ! grep '# Custom Code - PK' /etc/skel/.zshrc ; then
	echo '# Custom Code - PK' >> /etc/skel/.zshrc
    echo 'HISTFILE=~/log/zsh_history' >> /etc/skel/.zshrc
    echo 'export EDITOR=vim' >> /etc/skel/.zshrc
    echo 'export VISUAL=vim' >> /etc/skel/.zshrc
fi

touch /etc/skel/.vimrc
if ! grep '" Custom Code - PK' /etc/skel/.vimrc ; then
	echo '" Custom Code - PK' >> /etc/skel/.vimrc
	echo "set viminfo+=n~/log/viminfo" >> /etc/skel/.vimrc
fi

# Copy common files to root
cp /etc/skel/.viminfo /root/
cp /etc/skel/.zshrc /root/
cp /etc/skel/.vimrc /root/


# Change Shell
echo 'Changing shell for root to ZSH'
chsh --shell /bin/zsh
sed -i 's/bash/zsh/' /etc/default/useradd


# Setup some helper tools
echo 'Downloading ps_mem.py, mysqltuner and tuning-primer, etc'

PSMEMURL=http://www.pixelbeat.org/scripts/ps_mem.py
wget -q -O /root/ps_mem.py $PSMEMURL
chmod +x /root/ps_mem.py

TUNERURL=https://raw.github.com/major/MySQltuner-perl/master/mysqltuner.pl
wget -q -O /root/scripts/mysqltuner.pl $TUNERURL
chmod +x /root/scripts/mysqltuner.pl

PRIMERURL=https://launchpad.net/mysql-tuning-primer/trunk/1.6-r1/+download/tuning-primer.sh
wget -q -O /root/scripts/tuning-primer.sh $PRIMERURL
chmod +x /root/scripts/tuning-primer.sh

# Setup wp cli
echo 'Setting up WP CLI'
if [ ! -a /usr/local/bin/wp ]; then
	echo 'Setting up WP CLI'
	WPCLIURL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	curl --silent -O $WPCLIURL
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

# Setup fail2ban
# ref: https://krash.be/node/28
echo 'Setting up fail2ban'
echo '[DEFAULT]
findtime  = 5000
[sshd]
enabled = true' > /etc/fail2ban/jail.local

echo '[Init]
bantime = 10000' > /etc/fail2ban/action.d/firewallcmd-ipset.local

systemctl enable fail2ban
systemctl start fail2ban

# take a backup, after doing everything
echo 'Taking a final backup'
LT_DIRECTORY="/root/backups/etc-linux-tweaks-centos7-after-$(date +%F)"
if [ ! -d "$LT_DIRECTORY" ]; then
	cp -a /etc $LT_DIRECTORY
fi

# logout and then login to see the changes
echo 'All done.'
echo 'You may logout and then log back in to see all the changes'
echo
