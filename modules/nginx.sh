#!/bin/bash


# isntall Nginx
if ! command_exists nginx; then 
    echo "Nginx Installing"
    sudo apt install nginx -y
fi
