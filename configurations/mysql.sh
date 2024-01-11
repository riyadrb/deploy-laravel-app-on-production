# Check if MySQL is installed
if ! command_exists mysql; then
    echo "MySQL is not installed"
    sudo apt install mysql-server-8.0 -y
    # Set up MySQL initially with root password
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';"
    # Restart MySQL service to apply changes
    sudo systemctl restart mysql.service
fi

# Verify MySQL access
mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1;"  # This line will authenticate and check if MySQL is accessible

# Check the exit status of the above command to ensure successful authentication
if [[ $? == 0 ]]; then
    echo "MySQL setup successful. Proceeding with database operations..."
    # Create database if it doesn't exist
    mysql -u "$DB_USERNAME" -p"$DB_PASSWORD" -e"CREATE DATABASE IF NOT EXISTS $PROJECT_NAME;" || { echo "Faild to Create Mysql Database. Exiting."; exit 1; }
    
    
else
    echo "Failed to authenticate with MySQL. Exiting."
    exit 1
fi
