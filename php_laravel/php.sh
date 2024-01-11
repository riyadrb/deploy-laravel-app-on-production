function install_php_and_libraries() {
    PHP_VERSION=$1

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
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlrpc \
    php${PHP_VERSION}-xsl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-gettext \
    php${PHP_VERSION}-dom     

    if [[ $? == 0 ]]; then
        echo "PHP ${PHP_VERSION} and required libraries have been successfully installed."
    else
        echo "Failed to install PHP ${PHP_VERSION} and libraries. Please check logs for more details."
    fi
}

# Switching php version
function switch_php_version() {
    if [[ "$1" == "7" ]]; then
        sudo update-alternatives --set php /usr/bin/php${PHP_VERSION}
    elif [[ "$1" == "8" ]]; then
        sudo update-alternatives --set php /usr/bin/php${PHP_VERSION}
    else
        echo "Unsupported PHP Version."
        
    fi
}



# Detecting php version according to app
function get_laravel_php_version() {
    LARAVEL_PATH="/var/www/$PROJECT_NAME"  
    #<<<------------------------------------------------>>>
    if [[ -f "${LARAVEL_PATH}/composer.json" ]]; then
        # jq json perser tool
        PHP_VERSION=$(jq -r '.require.php' "${LARAVEL_PATH}/composer.json" | sed -E 's/\^([0-9]+\.[0-9]+)/\1/g' | tr '|' '\n' | sort -Vr | head -n1)
        echo "Detected PHP Version: php${PHP_VERSION}"

            # Checking if the Detected PHP Version is below 7.4 and setting it to 7.4
            if [[ "$(echo -e "7.4\n${PHP_VERSION}" | sort -V | head -n1)" != "7.4" ]]; then
                PHP_VERSION="7.4"
            elif [[ "$PHP_VERSION" == "8.0" ]]; then
                PHP_VERSION="8.1"
            fi
            echo "Adjusted PHP Version:php${PHP_VERSION}"



        #<<<----------------------------------------------------->>>
        if [[ "$PHP_VERSION" != "null" ]]; then
            echo "Laravel app requires PHP version: php${PHP_VERSION}"
            PHP_MAJOR_VERSION=$(echo "$PHP_VERSION" | sed 's/\^//' | cut -d '.' -f 1)


            #<<<------------------------------------------------>>>
            # Check for supported PHP versions
            if [[ "$PHP_MAJOR_VERSION" == "7" ]]; then
                if ! command_exists "php${PHP_VERSION}"; then
                    sudo add-apt-repository ppa:ondrej/php -y   #Added Ondrej repo as ubuntu 22.04's default does not have php7.4
                    sudo apt update
                    echo "PHP "$PHP_VERSION" is not installed. Installing..."
                    sudo apt install "php${PHP_VERSION}" "php${PHP_VERSION}"-fpm -y  # It will avoid installing default apache2 installation as i use nginx.
                fi
                # Calling Function with param
                install_php_and_libraries "$PHP_VERSION"
                # Calling Function with param
                switch_php_version "$PHP_MAJOR_VERSION"

            elif [[ "$PHP_MAJOR_VERSION" == "8" ]]; then
                if ! command_exists "php${PHP_VERSION}"; then
                    echo "PHP "$PHP_VERSION" is not installed. Installing..."
                    sudo apt install "php${PHP_VERSION}" "php${PHP_VERSION}"-fpm -y
                fi
                # Calling Function with param
                install_php_and_libraries "$PHP_VERSION"
                # Calling Function with param
                switch_php_version "$PHP_MAJOR_VERSION"

            else
                echo "Unsupported PHP version in Detection of php."
            fi
            #<<<-------------------------------------------->>>            
        else
            echo "Failed to detect a valid PHP version in composer.json."
        fi
        #<<<------------------------------------------------>>>

    else
        echo "Composer file not found in the specified Laravel app path."
    fi
    #<<<------------------------------------------------>>>

}


# Function call
get_laravel_php_version



