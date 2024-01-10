#!/bin/bash



LISTEN_PORT=8088
ROOT_PATH="/var/www/$PROJECT_NAME/public"
FASTCGI_PASS="unix:/run/php/php7.4-fpm.sock"


sed -e "s|DOMAIN_NAME|$DOMAIN_NAME|g" \
    -e "s|LISTEN_PORT|$LISTEN_PORT|g" \
    -e "s|ROOT_PATH|$ROOT_PATH|g" \
    -e "s|FASTCGI_PASS|$FASTCGI_PASS|g" "/etc/nginx/sites-available/template" > "/etc/nginx/sites-available/$DOMAIN_NAME"


ln -s  /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled
nginx -t
systemctl reload nginx

