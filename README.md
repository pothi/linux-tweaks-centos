Linux-Tweaks
============

Tweaks on bash, zsh, vim, tmux, etc on CentOS 7

## Install procedure

```bash
mkdir ~/scripts
curl -Sso ~/scripts/bootstrap_lt.sh https://raw.githubusercontent.com/pothi/linux-tweaks-centos/master/scripts/bootstrap-lt.sh
chmod +x ~/scripts/bootstrap_lt.sh

# go through the script to understand what it does. you are warned!
# vi ~/scripts/bootstrap_lt.sh

# run it and face the consequences
~/scripts/bootstrap_lt.sh

# get rid of all the evidences
rm ~/scripts/bootstrap_lt.sh
rmdir ~/scripts &> /dev/null
```
