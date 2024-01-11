# Configure nginx server
# LISTEN_PORT=80
ROOT_PATH="/var/www/$PROJECT_NAME/public"
# FASTCGI_PASS="unix:/run/php/php8.1-fpm.sock"
FASTCGI_PASS="unix:/run/php/php$PHP_VERSION-fpm.sock"


sed -e "s|DOMAIN_NAME|$DOMAIN_NAME|g" \
    -e "s|LISTEN_PORT|$LISTEN_PORT|g" \
    -e "s|ROOT_PATH|$ROOT_PATH|g" \
    -e "s|FASTCGI_PASS|$FASTCGI_PASS|g" "/root/test/template" > "/etc/nginx/sites-available/$DOMAIN_NAME"


ln -s  /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled
nginx -t
systemctl reload nginx
