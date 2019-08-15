FROM kikiyao/debian_php_dev_env:latest

RUN apt-get install git -y && \
    apt-get install inotify-tools -y && \
    git -C /var/www clone https://github.com/smarty-kiki/mvc_frame.git && \
    ln -fs /var/www/mvc_frame/project/config/development/nginx/mvc_frame.conf /etc/nginx/sites-enabled/default && \
    ln -fs /var/www/mvc_frame/project/config/development/supervisor/queue_worker.conf /etc/supervisor/conf.d/queue_worker.conf && \
    chmod 777 /var/www/mvc_frame/view/blade && \
    /bin/bash /var/www/mvc_frame/project/tool/dep_build.sh link && \
    /bin/bash /var/www/mvc_frame/project/tool/load_description_extension.sh

COPY ./inotify_watch.conf /etc/supervisor/conf.d/inotify_watch.conf
COPY ./shell/start.sh /bin/start
COPY ./shell/watch.sh /tmp/watch.sh
RUN chown root:root /bin/start && \
    chmod +x /bin/start

EXPOSE 80 3306

CMD start
