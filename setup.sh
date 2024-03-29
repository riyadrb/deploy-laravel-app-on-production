#!/bin/bash

# Set the script directory
# DIR="${BASH_SOURCE%/*}"
# if [[ ! -d "$DIR" ]]; then
#     DIR="$PWD"
# fi


#<<<-------------------------------------------------------------------------------------------------------------->>>

function command_exists() {
    command -v "$1" >/dev/null 2>&1
}
#<<<-------------------------------------------------------------------------------------------------------------->>>

read -p "Project Name: " PROJECT_NAME
read -p "Enter GitHub Repository URL: " GITHUB_URL
read -p "MySQL Username: " DB_USERNAME
read -s -p "Database Password: " DB_PASSWORD
echo
read -p "Enter Domain Name: " DOMAIN_NAME
read -p "Port Number: " LISTEN_PORT

mkdir -p "/var/www/$PROJECT_NAME"
cd "/var/www/$PROJECT_NAME" || exit


#<<<-------------------------------------------------------------------------------------------------------------->>>

required_commands=("git" "curl" "unzip" "expect" "jq")

for cmd in "${required_commands[@]}"; 
do 
    if ! command_exists "$cmd"; then
        echo "$cmd is Not Installed!"
        sudo apt install "$cmd" -y
    fi
done

git clone "$GITHUB_URL" . || { echo "Failed to Clone Repository. Exiting"; exit 1; }


#<<<-------------------------------------------------------------------------------------------------------------->>>
# Installing composer and laravel
function install_laravel() {
    if ! command_exists composer &> /dev/null; then
        echo "Installing composer..."
        sudo apt install php-cli php-mbstring
        curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

        if ! command_exists composer &> /dev/null; then
             echo "ERROR: Composer installation failed" >&2
            exit 1
        fi
        echo "Composer has been installed successfully."
    else
        echo "Composer is already installed."
    fi

    composer global require "laravel/installer"
    
    if [[ $? == 0 ]]; then
        echo "Laravel has been installed globally."
    else
        echo "Failed to install Laravel globally. Please check logs for more details."
    fi
}

install_laravel


#<<<-------------------------------------------------------------------------------------------------------------->>>

# Installing Nginx
if ! command_exists nginx; then
    echo "Nginx Installing"
    sudo apt update
    sudo apt install nginx -y
fi



#<<<-------------------------------------------------------------------------------------------------------------->>>

function install_php_and_libraries() {
    PHP_VERSION=$1

    sudo apt install -y \
    php"${PHP_VERSION}"-fpm \
    php"${PHP_VERSION}"-mysql \
    php"${PHP_VERSION}"-zip \
    php"${PHP_VERSION}"-curl \
    php"${PHP_VERSION}"-gd \
    php"${PHP_VERSION}"-intl \
    php"${PHP_VERSION}"-imagick \
    php"${PHP_VERSION}"-imap \
    php"${PHP_VERSION}"-memcache \
    php"${PHP_VERSION}"-pspell \
    php"${PHP_VERSION}"-sqlite3 \
    php"${PHP_VERSION}"-tidy \
    php"${PHP_VERSION}"-xml \
    php"${PHP_VERSION}"-xmlrpc \
    php"${PHP_VERSION}"-xsl \
    php"${PHP_VERSION}"-mbstring \
    php"${PHP_VERSION}"-gettext \
    php"${PHP_VERSION}"-dom     

    if [[ $? == 0 ]]; then
        echo "PHP ${PHP_VERSION} and required libraries have been successfully installed."
    else
        echo "Failed to install PHP ${PHP_VERSION} and libraries. Please check logs for more details."
    fi
}

#<<<-------------------------------------------------------------------------------------------------------------->>>

# Switching php version
function switch_php_version() {
    if [[ "$1" == "7" ]]; then
        sudo update-alternatives --set php /usr/bin/php"${PHP_VERSION}"
    elif [[ "$1" == "8" ]]; then
        sudo update-alternatives --set php /usr/bin/php"${PHP_VERSION}"
    else
        echo "Unsupported PHP Version."
        
    fi
}


#<<<-------------------------------------------------------------------------------------------------------------->>>

# Detecting php version according to the app
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
                    echo "PHP $PHP_VERSION is not installed. Installing..."
                    sudo apt install "php${PHP_VERSION}" "php${PHP_VERSION}"-fpm -y  # It will avoid installing default apache2 installation as i use nginx.
                fi
                install_php_and_libraries "$PHP_VERSION"
                switch_php_version "$PHP_MAJOR_VERSION"

            elif [[ "$PHP_MAJOR_VERSION" == "8" ]]; then
                if ! command_exists "php${PHP_VERSION}"; then
                    echo "PHP $PHP_VERSION is not installed. Installing..."
                    sudo apt install "php${PHP_VERSION}" "php${PHP_VERSION}"-fpm -y
                fi
                install_php_and_libraries "$PHP_VERSION"
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

get_laravel_php_version

#<<<-------------------------------------------------------------------------------------------------------------->>>


composer install || { echo "Faild to Install Composer Dependencies. Exiting."; exit 1; }

cp .env.example .env

php artisan key:generate
php artisan storage:link

#<<<------------------------------------------------------------------------------------------------------------->>>

sed -i -e "s|^DB_DATABASE=.*|DB_DATABASE=\"$PROJECT_NAME\"|" \
       -e "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USERNAME|" \
       -e "s|^DB_PASSWORD=.*|DB_PASSWORD=\"$DB_PASSWORD\"|" \
       -e "s|^APP_NAME=.*|APP_NAME=$PROJECT_NAME|" \
       -e "s|^APP_ENV=.*|APP_ENV=production|" \
       -e "s|^APP_DEBUG=.*|APP_DEBUG=true|" \
       -e "s|^APP_URL=.*|APP_URL=$DOMAIN_NAME|" .env

#<<<------------------------------------------------------------------------------------------------------------->>>


#<<<------------------------------------------------------------------------------------------------------------->>>


# Check if MySQL is installed
if ! command_exists mysql; then
    echo "MySQL is not installed"
    sudo apt install mysql-server-8.0 -y
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';"
    sudo systemctl restart mysql.service
fi

# Verify MySQL access
mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1;"  # This line will authenticate and check if MySQL is accessible

# Check the exit status of the above command to ensure successful authentication
if [[ $? == 0 ]]; then
    echo "MySQL setup successful. Proceeding with database operations..."
    mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" -e"CREATE DATABASE IF NOT EXISTS $PROJECT_NAME;" || { echo "Faild to Create Mysql Database. Exiting."; exit 1; }
    
    
else
    echo "Failed to authenticate with MySQL. Exiting."
    exit 1
fi

#<<<------------------------------------------------------------------------------------------------------------->>>

php artisan migrate:fresh --seed || { echo "Failed to Run Migrations. Exiting."; exit 1; }  

chmod -R 775 storage
chmod -R 775 bootstrap/cache

sudo chown -R "$USER":www-data storage
sudo chown -R "$USER":www-data bootstrap/cache

#<<<------------------------------------------------------------------------------------------------------------->>>

# Configure Nginx server
ROOT_PATH="/var/www/$PROJECT_NAME/public"
FASTCGI_PASS="unix:/run/php/php$PHP_VERSION-fpm.sock"


sed -e "s|DOMAIN_NAME|$DOMAIN_NAME|g" \
    -e "s|LISTEN_PORT|$LISTEN_PORT|g" \
    -e "s|ROOT_PATH|$ROOT_PATH|g" \
    -e "s|FASTCGI_PASS|$FASTCGI_PASS|g" "$HOME/template" > "/etc/nginx/sites-available/$DOMAIN_NAME"


ln -s  /etc/nginx/sites-available/"$DOMAIN_NAME" /etc/nginx/sites-enabled
nginx -t
systemctl reload nginx
#<<<------------------------------------------------------------------------------------------------------------->>>



# certbot --nginx -d $DOMAIN_NAME


