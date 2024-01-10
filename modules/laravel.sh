#!/bin/bash

# Function to install Laravel globally
function install_laravel() {

    # PHP_VERSION=$1

    # Check if composer is installed
    if ! command -v composer &> /dev/null; then
        echo "Composer is not installed. Installing..."
        # Install Composer
        EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

        if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
            >&2 echo "ERROR: Invalid composer installer signature"
            rm composer-setup.php
            exit 1
        fi

        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
        rm composer-setup.php

        if ! command -v composer &> /dev/null; then
            >&2 echo "ERROR: Composer installation failed"
            exit 1
        fi

        echo "Composer has been installed successfully."
    else
        echo "Composer is already installed."
    fi


    # Install Laravel globally using detected PHP version
    composer global require "laravel/installer"
    
    if [ $? -eq 0 ]; then
        echo "Laravel has been installed globally."
    else
        echo "Failed to install Laravel globally. Please check logs for more details."
    fi
}

install_laravel #"$1"
