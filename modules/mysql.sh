#!/bin/bash


#installing mysql
if ! command_exists mysql; then 
    echo "MySQL is not installed"
    sudo apt install mysql-server-8.0 -y
fi