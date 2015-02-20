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
yum install zsh zsh-html git vim -y -q

mkdir ~/backups &> /dev/null
mkdir -p ~/backups/{files,databases} ~/{log,tmp,others,scripts} &> /dev/null

# take a backup
LT_DIRECTORY="/root/backups/etc-$(date +%F)-linux-tweaks"
if [ ! -d "$LT_DIRECTORY" ]; then
	cp -a /etc $LT_DIRECTORY
fi

# get the source from Github
rm -rf ~/lt
git clone --recursive https://github.com/pothi/linux-tweaks-centos.git ~/lt

# Shell related configs
cp ~/lt/tiny_* /etc/profile.d/
cat ~/lt/zprofile > /etc/zprofile
cat ~/lt/zshrc > /etc/zshrc

# Vim related configs
cat ~/lt/vimrc.local > /etc/vimrc
cp -a ~/lt/vim/* /usr/share/vim/vim74/

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
cat ~/lt/tmux.conf > /etc/tmux.conf
cat ~/lt/gitconfig > /etc/gitconfig

# Clean up
rm -rf ~/lt/

# Change Shell
chsh --shell /bin/zsh
# chsh --shell /bin/zsh pothi
# chsh --shell /bin/zsh client

#### Update Pathogen (optional)
curl -Sso /usr/share/vim/vim74/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

# logout and then login to see the changes
