#!/bin/bash

PROJECT_PATH=/var/www/mvc_frame
env=development

inotifywait -qm -e CREATE -e MODIFY -e DELETE $PROJECT_PATH/domain/description/ | while read -r directory event filename;do
if [[ $filename == *.yml ]];then

    entity_name=${filename%.*}

    ENV=$env /usr/bin/php /var/www/mvc_frame/public/cli.php migrate:reset

    rm -rf $PROJECT_PATH/view/$entity_name
    rm -rf $PROJECT_PATH/domain/dao/$entity_name.php
    rm -rf $PROJECT_PATH/domain/entity/$entity_name.php
    rm -rf $PROJECT_PATH/command/migration/*_$entity_name.sql
    rm -rf $PROJECT_PATH/controller/$entity_name.php

    grep -v \/$entity_name $PROJECT_PATH/public/index.php > /tmp/index.php
    mv /tmp/index.php $PROJECT_PATH/public/index.php

    if [ "$event" == "CREATE" ];then
        echo $filename $event

        ENV=$env /usr/bin/php $PROJECT_PATH/public/cli.php entity:make-from-description --entity_name=$entity_name
        /bin/bash $PROJECT_PATH/project/tool/classmap.sh $PROJECT_PATH/domain
        ENV=$env /usr/bin/php /var/www/mvc_frame/public/cli.php migrate

        ENV=$env /usr/bin/php $PROJECT_PATH/public/cli.php crud:make-from-description --entity_name=$entity_name
        /bin/sed -i "/init\ controller/a\include\ CONTROLLER_DIR\.\'\/$entity_name\.php\'\;" $PROJECT_PATH/public/index.php
    fi

    if [ "$event" == "MODIFY" ];then
        echo $filename $event

        ENV=$env /usr/bin/php $PROJECT_PATH/public/cli.php entity:make-from-description --entity_name=$entity_name
        /bin/bash $PROJECT_PATH/project/tool/classmap.sh $PROJECT_PATH/domain
        ENV=$env /usr/bin/php /var/www/mvc_frame/public/cli.php migrate

        ENV=$env /usr/bin/php $PROJECT_PATH/public/cli.php crud:make-from-description --entity_name=$entity_name
        /bin/sed -i "/init\ controller/a\include\ CONTROLLER_DIR\.\'\/$entity_name\.php\'\;" $PROJECT_PATH/public/index.php
    fi

    if [ "$event" == "DELETE" ];then
        echo $filename $event

        /bin/bash $PROJECT_PATH/project/tool/classmap.sh $PROJECT_PATH/domain
        ENV=$env /usr/bin/php /var/www/mvc_frame/public/cli.php migrate
    fi
fi
done
