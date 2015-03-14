#!/bin/bash

# Tweaks on bash, zsh, vim, tmux, etc on CentOS

# as root
# if [[ $USER != "root" ]]; then
	# echo "This script must be run as root"
	# exit 1
# fi

# install dependencies
echo 'Installing dependencies...'
yum update -y -q
yum install zsh zsh-html git vim bind-utils zip -y -q

mkdir ~/{backups,log,tmp,others,scripts,git,src} &> /dev/null

# take a backup
LT_DIRECTORY="/root/backups/etc-$(date +%F)-linux-tweaks-centos"
if [ ! -d "$LT_DIRECTORY" ]; then
	cp -a /etc $LT_DIRECTORY
fi

# get the source from Github
rm -rf ~/ltc
git clone --recursive https://github.com/pothi/linux-tweaks-centos.git ~/ltc

# Shell related configs
cp ~/ltc/tiny_* /etc/profile.d/
cat ~/ltc/zprofile >> /etc/zprofile
cat ~/ltc/zshrc >> /etc/zshrc

# Vim related configs
cat ~/ltc/vimrc.local >> /etc/vimrc
cp -a ~/ltc/vim/* /usr/share/vim/vim74/

# Common for all users
touch /etc/skel/.viminfo
echo 'HISTFILE=~/log/zsh_history' >> /etc/skel/.zshrc
echo 'export EDITOR=vim' >> /etc/skel/.zshrc
echo 'export VISUAL=vim' >> /etc/skel/.zshrc

echo "set viminfo='10,\"100,:20,%,n~/log/viminfo" >> /etc/skel/.vimrc

# For root
cp /etc/skel/.zshrc ~/
cp /etc/skel/.vimrc ~/
touch ~/.viminfo

# Misc files
cat ~/ltc/tmux.conf > /etc/tmux.conf
cat ~/ltc/gitconfig > /etc/gitconfig

# Clean up
rm -rf ~/ltc/

# Change Shell
chsh --shell /bin/zsh

#### Update Pathogen (optional)
curl -Sso /usr/share/vim/vim74/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

# logout and then login to see the changes
