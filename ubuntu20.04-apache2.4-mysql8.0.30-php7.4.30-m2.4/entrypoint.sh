#!/bin/bash
set -e

update-alternatives --set php /usr/bin/php8.1
service php8.1-fpm start

a2enmod rewrite ssl actions alias proxy proxy_fcgi proxy_http

a2dissite 000-default.conf
a2dissite default-ssl.conf
a2ensite m24.conf

# apache2ctl configtest

service apache2 restart

# apache2 -e info

# systemctl status apache2.service

echo "$@"
exec "$@"

env >> /etc/environment
exec "cron -f"

