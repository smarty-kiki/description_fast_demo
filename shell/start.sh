#!/bin/bash

service nginx start
service mysql start
service redis-server start
service php7.0-fpm start
service beanstalkd start
service supervisor start
service mongodb start

mysql -e "create database \`default\`"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password'"

PROJECT_PATH=/var/www/mvc_frame

/usr/bin/php $PROJECT_PATH/public/cli.php entity:make-from-description
/bin/bash $PROJECT_PATH/project/tool/classmap.sh $PROJECT_PATH/domain
/usr/bin/php /var/www/mvc_frame/public/cli.php migrate:install
/usr/bin/php /var/www/mvc_frame/public/cli.php migrate

for f in `ls $PROJECT_PATH/domain/description`;do

    entity_name=${f%.*}

    /usr/bin/php $PROJECT_PATH/public/cli.php crud:make-from-description --entity_name=$entity_name
    /bin/sed -i "/init\ controller/a\include\ CONTROLLER_DIR\.\'\/$entity_name\.php\'\;" $PROJECT_PATH/public/index.php
done

tail -n 100 -f /var/log/nginx/access.log /var/log/nginx/error.log /var/log/php7.0-fpm.log /var/log/mysql/error.log /var/log/redis/redis-server.log /var/log/supervisor/*
