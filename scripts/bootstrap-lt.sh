#!/bin/bash

# Tweaks on bash, zsh, vim, tmux, etc on CentOS

# as root
# if [[ $USER != "root" ]]; then
	# echo "This script must be run as root"
	# exit 1
# fi

mkdir ~/{backups,git,log,others,scripts,src,tmp} &> /dev/null

# take a backup
echo 'Taking an initial backup'
echo 'Taking an initial backup' >> /root/log/linux-tweaks.log
LT_DIRECTORY="/root/backups/etc-linux-tweaks-centos7-before-$(date +%F)"
if [ ! -d "$LT_DIRECTORY" ]; then
	cp -a /etc $LT_DIRECTORY
fi

# install dependencies
echo 'Updating the server'
echo 'Updating the server' >> /root/log/linux-tweaks.log
yum update -y -q &>> /root/log/linux-tweaks.log


echo 'Install prerequisites'
echo 'Install prerequisites' >> /root/log/linux-tweaks.log
yum install -y epel-release &>> /root/log/linux-tweaks.log
yum install -y zsh zsh-html \
	tmux \
	gcc \
	git subversion \
	vim vim-enhanced \
	bind-utils \
	zip unzip \
	mlocate \
	python-pip \
	logwatch postfix \
	fail2ban-firewalld fail2ban-systemd \
	ruby ruby-gems ruby-devel libxml2-devel libxslt-devel gcc-c++ \
	yum-cron \
	&>> /root/log/linux-tweaks.log


echo 'Install AWS CLI tools'
echo 'Install AWS CLI tools' >> /root/log/linux-tweaks.log
pip install awscli &>> /root/log/linux-tweaks.log


# get the source from Github
echo 'Downloading Linux Tweaks from Github repo'
echo 'Downloading Linux Tweaks from Github repo' &>> /root/log/linux-tweaks.log
rm -rf ~/ltc &> /dev/null
git clone --recursive https://github.com/pothi/linux-tweaks-centos.git ~/ltc &>> /root/log/linux-tweaks.log

# Shell related configs
cp ~/ltc/tiny_* /etc/profile.d/
cat ~/ltc/zprofile >> /etc/zprofile
cat ~/ltc/zshrc >> /etc/zshrc

# Vim related configs
cat ~/ltc/vimrc.local >> /etc/vimrc
cp -a ~/ltc/vim/* /usr/share/vim/vim74/

# Misc files
cat ~/ltc/tmux.conf > /etc/tmux.conf
cat ~/ltc/gitconfig > /etc/gitconfig

# Clean up
rm -rf ~/ltc/


# Common for all users
echo 'Setting up skel directory'
echo 'Setting up skel directory' >> /root/log/linux-tweaks.log
touch /etc/skel/.viminfo &> /dev/null
echo 'HISTFILE=~/log/zsh_history' > /etc/skel/.zshrc
echo 'export EDITOR=vim' >> /etc/skel/.zshrc
echo 'export VISUAL=vim' >> /etc/skel/.zshrc

echo "set viminfo='10,\"100,:20,%,n/root/log/viminfo" > /etc/skel/.vimrc

# Copy common files to root
cp /etc/skel/.viminfo /root/
cp /etc/skel/.zshrc /root/
cp /etc/skel/.vimrc /root/


# Change Shell
echo 'Changing shell for root to ZSH'
echo 'Changing shell for root to ZSH' >> /root/log/linux-tweaks.log
chsh --shell /bin/zsh
sed -i 's/bash/zsh/' /etc/default/useradd


#### Update Pathogen (optional)
echo 'Updating Pathogen (for VIM)'
echo 'Updating Pathogen (for VIM)' >> /root/log/linux-tweaks.log
curl -Sso /usr/share/vim/vim74/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim


# Setup some helper tools
echo 'Downloading ps_mem.py, mysqltuner and tuning-primer, etc'
echo 'Downloading ps_mem.py, mysqltuner and tuning-primer, etc' >> /root/log/linux-tweaks.log
wget -q -O /root/ps_mem.py http://www.pixelbeat.org/scripts/ps_mem.py && chmod +x /root/ps_mem.py &>> /root/log/linux-tweaks.log
wget -q -O /root/scripts/mysqltuner.pl https://raw.github.com/major/MySQLTuner-perl/master/mysqltuner.pl && chmod +x /root/scripts/mysqltuner.pl &>> /root/log/linux-tweaks.log
wget -q -O /root/scripts/tuning-primer.sh https://launchpad.net/mysql-tuning-primer/trunk/1.6-r1/+download/tuning-primer.sh && chmod +x /root/scripts/tuning-primer.sh &>> /root/log/linux-tweaks.log


# Setup wp cli
echo 'Setting up WP CLI'
echo 'Setting up WP CLI' >> /root/log/linux-tweaks.log
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &>> /root/log/linux-tweaks.log
chmod +x wp-cli.phar &>> /root/log/linux-tweaks.log
mv wp-cli.phar /usr/local/bin/wp &>> /root/log/linux-tweaks.log


# Setup fail2ban
# ref: https://krash.be/node/28
echo 'Setting up fail2ban'
echo 'Setting up fail2ban' >> /root/log/linux-tweaks.log
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
echo 'Taking a final backup' >> /root/log/linux-tweaks.log
LT_DIRECTORY="/root/backups/etc-linux-tweaks-centos7-after-$(date +%F)"
if [ ! -d "$LT_DIRECTORY" ]; then
	cp -a /etc $LT_DIRECTORY
fi


echo 'Install Ruby Gems... please be patient'
echo 'Install Ruby Gems... please be patient' >> /root/log/linux-tweaks.log
gem install nokogiri -N &>> /root/log/linux-tweaks.log
if [ "$?" == "0" ]; then
	gem install backup -N &>> /root/log/linux-tweaks.log
fi


# logout and then login to see the changes
echo 'All done.'
echo 'You may logout and then log back in to see all the changes'
echo
