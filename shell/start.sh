#!/bin/bash

if  [ -n "$TIMEZONE" ]
then
    cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    echo $TIMEZONE >/etc/timezone
fi

service php7.4-fpm start
service nginx start
service mysql start
service redis-server start
service beanstalkd start
service supervisor start
service mongodb start

mysql -e "create database \`default\`"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password'"

date > /tmp/php_exception.log
date > /tmp/php_notice.log
date > /tmp/php_module.log

/bin/bash /var/www/mvc_frame/project/tool/development/after_env_start.sh
/bin/bash /var/www/mvc_frame/project/tool/development/fast_demo_watch.sh
