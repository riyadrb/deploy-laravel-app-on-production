# Installing Nginx
if ! command_exists nginx; then
    echo "Nginx Installing"
    sudo apt update
    sudo apt install nginx -y
fi
