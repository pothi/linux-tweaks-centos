Linux-Tweaks
============

Tweaks on bash, zsh, vim, tmux, etc on CentOS

## Install procedure

```bash
# as root
# yum install zsh zsh-html -y

# take a backup
cp -a /etc ~/backups/etc-$(date +%F)-linux-tweaks

# get the source from Github
cd $HOME && git clone --recursive git://github.com/pothi/linux-tweaks.git

# Shell related configs
cd ~/linux-tweaks; cp tiny_* /etc/profile.d/
cat zprofile > /etc/zprofile && cat zshrc > /etc/zshrc

# Vim related configs
cat vimrc.local > /etc/vim/vimrc.local && cp -a vim/* /usr/share/vim/vimcurrent/

# Common for all users
touch /etc/skel/.viminfo
echo 'HISTFILE=~/log/zsh_history' >> /etc/skel/.zshrc
echo 'export EDITOR=vim' >> /etc/skel/.zshrc
echo 'export VISUAL=vim' >> /etc/skel/.zshrc

echo "set viminfo='10,\"100,:20,%,n~/log/viminfo" >> /etc/skel/.vimrc

# Misc files
cat tmux.conf > /etc/tmux.conf && cat gitconfig > /etc/gitconfig

# Clean up
cd $HOME; rm -rf linux-tweaks/

# Change Shell
chsh --shell /bin/zsh
chsh --shell /bin/zsh pothi
# chsh --shell /bin/zsh sftpuser
```

#### Update Pathogen (optional)
```bash
curl -Sso /usr/share/vim/vimcurrent/autoload/pathogen.vim \
    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
```
