Linux-Tweaks
============

Tweaks on bash, zsh, vim, tmux, etc on CentOS

## Install procedure

mkdir ~/scripts
curl -Sso ~/scripts/bootstrap_lt.sh https://raw.githubusercontent.com/pothi/linux-tweaks-centos/master/bootstrap.sh
chmod +x ~/scripts/bootstrap_lt.sh

# go through the script to understand what it does. you are warned!
# vi ~/scripts/bootstrap_lt.sh

# run it and face the consequences
~/scripts/bootstrap_lt.sh

# get rid of all the evidences
rm ~/scripts/bootstrap_lt.sh
rmdir ~/scripts &> /dev/null
