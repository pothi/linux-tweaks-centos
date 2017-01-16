#!/bin/bash

# Variable
# please set them directly in ~/.my.exports file
# MY_SFTP_USER=
# MY_PHP_MAX_CHILDREN=

LOG_FILE="/root/log/php-install.log"
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)

source /root/.my.exports

if [ "$MY_SFTP_USER" == '' ]; then
    MY_SFTP_USER='pothi'
fi


# Setup MySQL, memcached, & PHP

yum install -y mariadb-server
systemctl enable mariadb
systemctl start mariadb

yum install redis -y
systemctl enable mariadb
systemctl start mariadb

# https://support.rackspace.com/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat/
# https://ius.io/GettingStarted/
wget https://centos7.iuscommunity.org/ius-release.rpm
rpm -Uvh ius-release*.rpm

PHP_VER=70
PHP_PACKAGES="php{PHP_VER}u-fpm php{PHP_VER}u-pecl-redis php{PHP_VER}u-mysqlnd php{PHP_VER}u-gd php{PHP_VER}u-mcrypt php{PHP_VER}u-xml php{PHP_VER}u-mbstring php{PHP_VER}u-curl"
yum install -y 

BPHP_DIRECTORY="/root/backups/etc-php-before-$(date +%F)"
if [ ! -d "$BPHP_DIRECTORY" ]; then
	cp -a /etc $BPHP_DIRECTORY
fi

echo 'Setting up memory limits'
if [ -f "/etc/php.ini" ]; then
  PHP_INI=/etc/php.ini
else
  echo '/etc/php.ini is not found. Please check your PHP installation!'
fi

sed -i '/cgi.fix_pathinfo=/ s/;\(cgi.fix_pathinfo=\)1/\10/' $PHP_INI
sed -i -e '/^max_execution_time/ s/=.*/= 300/' -e '/^max_input_time/ s/=.*/= 600/' $PHP_INI
sed -i -e '/^memory_limit/ s/=.*/= 256M/' $PHP_INI
sed -i -e '/^post_max_size/ s/=.*/= 64M/'      -e '/^upload_max_filesize/ s/=.*/= 64M/' $PHP_INI

echo 'Setting up sessions...'

sed -i -e '/^session.save_handler/ s/=.*/= redis/' $PHP_INI
sed -i -e '/^;session.save_path/ s/.*/session.save_path = "127.0.0.1:6379"/' $PHP_INI

# Disable user.ini
sed -i -e '/^;user_ini.filename =$/ s/;//' $PHP_INI

POOLPHP=/etc/php-fpm.d/${MY_SFTP_USER}.conf
mv /etc/php-fpm.d/www.conf $POOLPHP

echo 'Setting up the user'
# Change default user
sed -i -e 's/^\[www\]$/['$MY_SFTP_USER']/' $POOLPHP
sed -i -e '/^\(user\|group\)/ s/=.*/= '$MY_SFTP_USER'/' $POOLPHP
sed -i -e '/^;listen.\(owner\|group\|mode\)/ s/^;//' $POOLPHP
sed -i -e '/^listen.mode = / s/[0-9]\{4\}/0666/' $POOLPHP
sed -i -e '/^listen.\(owner\|group\)/ s/=.*/= '$MY_SFTP_USER'/' $POOLPHP

echo 'Setting up the port / socket for PHP'
# Setup port / socket
# LISTEN='127.0.0.1:9006'
LISTEN="/run/php-fpm/${MY_SFTP_USER}.sock"
sed -i '/^listen =/ s/=.*/= '$LISTEN'/' $POOLPHP

echo 'Setting up the processes...'
PHP_MIN=$(expr $MY_PHP_MAX_CHILDREN / 10)
PHP_MAX=$(expr $MY_PHP_MAX_CHILDREN / 2)
PHP_DIFF=$(expr $PHP_MAX - $PHP_MIN)
PHP_START=$(expr $PHP_MIN + $PHP_DIFF / 2)

if [ "$MY_PHP_MAX_CHILDREN" != '' ]; then
  # sed -i '/^pm = dynamic/ s/=.*/= static/' $POOLPHP
  sed -i '/^pm.max_children/ s/=.*/= '$MY_PHP_MAX_CHILDREN'/' $POOLPHP
  sed -i '/^pm.start_servers/ s/=.*/= '$PHP_START'/' $POOLPHP
  sed -i '/^pm.min_spare_servers/ s/=.*/= '$PHP_MIN'/' $POOLPHP
  sed -i '/^pm.max_spare_servers/ s/=.*/= '$PHP_MAX'/' $POOLPHP
fi

sed -i '/^;catch_workers_output/ s/^;//' $POOLPHP
sed -i '/^;pm.process_idle_timeout/ s/^;//' $POOLPHP
sed -i '/^;pm.max_requests/ s/^;//' $POOLPHP
sed -i '/^;pm.status_path/ s/^;//' $POOLPHP
sed -i '/^;ping.path/ s/^;//' $POOLPHP
sed -i '/^;ping.response/ s/^;//' $POOLPHP

# automatic restart upon random failure - directly from http://tweaked.io/guide/nginx/
FPMCONF="/etc/php-fpm.conf"
sed -i '/^;emergency_restart_threshold/ s/^;//' $FPMCONF
sed -i '/^emergency_restart_threshold/ s/=.*$/= '$PHP_MIN'/' $FPMCONF
sed -i '/^;emergency_restart_interval/ s/^;//' $FPMCONF
sed -i '/^emergency_restart_interval/ s/=.*$/= 1m/' $FPMCONF
sed -i '/^;process_control_timeout/ s/^;//' $FPMCONF
sed -i '/^process_control_timeout/ s/=.*$/= 10s/' $FPMCONF

systemctl enable php-fpm
systemctl start php-fpm

echo
echo 'All done. PHP FPM is listening on '$LISTEN
echo