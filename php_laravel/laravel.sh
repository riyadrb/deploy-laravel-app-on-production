# Installing composer and laravel
function install_laravel() {
    if ! command_exists composer &> /dev/null; then
        # Installing composer
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

# Function call for installing laravel 
install_laravel