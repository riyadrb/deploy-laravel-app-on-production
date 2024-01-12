# Laravel Software Deployment Script
Automate the setup of a Laravel environment on your server with this script. It streamlines the installation and configuration of essential components, including Nginx, PHP (supports multiple versions), MySQL, Composer, and Laravel. The script intelligently checks your system for required software and installs them if missing. It seamlessly handles PHP version requirements, allowing you to switch between versions as needed. Save time and effort in setting up your Laravel application with this efficient and automated script.

## Effortless Deployment:
Use this script for quick and hassle-free deployment of Laravel applications. Focus on your development, and let the script take care of the intricate setup process. Save time and ensure a consistent and reliable environment for your Laravel projects.

## Prerequisites
Before running the script, ensure the following prerequisites are met:

- A server running Ubuntu.
- Git installed on the server.
- Internet connectivity on the server for package installations.


## Usage

### 1. Clone Repository:
Clone the repository to your home directory:

```bash
    git clone https://github.com/riyadrb/laravel-env-setup-automation.git
```

### 2. Prepare Nginx Template File:

Inside the repository, you will find an Nginx template file, Make a copy of this template and customize it according to your project's needs.

Update the placeholders for `DOMAIN_NAME`, `LISTEN_PORT`, `ROOT_PATH`, and `FASTCGI_PASS` with your specific values if needed.

### 3. Run the Setup Script:

```bash
    ./setup.sh
```
### 4. Follow On-Screen Instructions:

The script will prompt you for information such as the project name, GitHub repository URL, MySQL Username,MySQL Database Password, and Domain name. Enter the required information as prompted.

### 5. Automated Setup:

The script will automatically:

- Install and configure Nginx.
- Detect the required PHP version for your Laravel app and install it.
- Set up MySQL with a secure root password.
- Install Composer globally.
- Install Laravel globally.
- Configure your Laravel app with the specified database details.
- Set up Nginx server block for your Laravel app.
- Start the Nginx service.

### 6. Access Your Laravel App:

Once the script completes successfully, your Laravel app should be accessible at the specified domain.

### Notes:

- This script is designed for Ubuntu-based servers.
- Ensure that you have the necessary permissions to execute the script.
- It's recommended to review the script before execution to understand the steps it will perform.

### Troubleshooting:

If any issues occur during the setup, check the script logs for more details. Feel free to open an issue on the repository for assistance.

### Customizing Nginx Configuration:

The Nginx template file provided in this repository serves as a starting point. Customize it further to meet the specific requirements of your Laravel application. And keep it in same directory where the **setup.sh** script file is located.

### SSL Certificate (Optional):
Certbot for SSL certificate installation is commented out. Uncomment and customize if SSL is required.

### License:

This project is licensed under the [MIT License](https://opensource.org/license/mit/). Feel free to customize and use it according to your needs.

## Script Details:

### Script Structure:

- The script is organized into functions for clarity and modularity.
- It checks for the existence of required commands and installs them if not found.
- It clones the specified Laravel project from the provided GitHub URL.
- Installs Composer and Laravel globally.
- Installs Nginx, PHP, and required PHP extensions.
- Detects the PHP version required by the Laravel app and installs it.
- Configures MySQL and creates the database for the Laravel app.
- Runs Laravel migrations and sets necessary file permissions.
- Configures the Nginx server block for the Laravel app.

### Nginx Template File:

The Nginx template file is a placeholder for the server block configuration.

- Customize the file according to your project's requirements, updating placeholders with actual values.

### Additional Configuration:

- The script utilizes `jq` for parsing JSON and `expect` for automating MySQL setup.

<!-- ## Author:

- [Your Name]
- [Your Email]
- [Your GitHub] -->

#### Feel free to contribute to the improvement of this script or report any issues. Happy coding!

