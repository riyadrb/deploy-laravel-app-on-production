#!/bin/bash


# Function to install required PHP version and libraries
function install_php_and_libraries() {

    PHP_VERSION=$1

    sudo apt update

    # Install PHP and libraries for the specified version
    sudo apt install -y \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-memcache \
        php${PHP_VERSION}-pspell \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-tidy \
        php${PHP_VERSION}-xmlrpc \
        php${PHP_VERSION}-xsl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-gettext

    if [ $? -eq 0 ]; then
        echo "PHP ${PHP_VERSION} and required libraries have been successfully installed."
    else
        echo "Failed to install PHP ${PHP_VERSION} and libraries. Please check logs for more details."
    fi
}

# Function to determine the PHP version used by Laravel
function get_laravel_php_version() {
    LARAVEL_PATH="/var/www/$PROJECT_NAME"  

    # Check if composer.json exists in the Laravel app directory
    if [ -f "${LARAVEL_PATH}/composer.json" ]; then
        PHP_VERSION=$(grep -oP '(?<="php": ")[0-9]+\.[0-9]+' ${LARAVEL_PATH}/composer.json)
        if [ -n "$PHP_VERSION" ]; then
            echo "Laravel app requires PHP version ${PHP_VERSION}"
            install_php_and_libraries "${PHP_VERSION}"
        else
            echo "Unable to detect PHP version required by the Laravel app."
        fi
    else
        echo "Composer file not found in the specified Laravel app path."
    fi
}

# Check and install PHP version required by the Laravel app
get_laravel_php_version




