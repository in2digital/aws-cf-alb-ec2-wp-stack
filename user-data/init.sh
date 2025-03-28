#!/bin/bash
set -euxo pipefail

# Log all output to a file
mkdir -p /etc/logs
exec > >(tee -a /etc/logs/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# --- CONFIG ---
REPO_BASE="https://raw.githubusercontent.com/in2digital/aws-cf-alb-ec2-stack/main"

# --- SYSTEM PREP ---
apt update && apt upgrade -y
apt install -y nginx php-fpm php-mysql php-xml php-curl php-mbstring php-zip php-gd php-imagick curl unzip

# --- INSTALL CLOUDWATCH AGENT ---
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb || apt install -f -y
rm -f amazon-cloudwatch-agent.deb

# --- DETECT PHP VERSION ---
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

# --- CONFIGURE PHP-FPM ---
systemctl stop php${PHP_VERSION}-fpm
rm -f /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
curl -fsSL "$REPO_BASE/php-fpm/wordpress.conf" -o /etc/php/${PHP_VERSION}/fpm/pool.d/wordpress.conf
systemctl start php${PHP_VERSION}-fpm
systemctl enable php${PHP_VERSION}-fpm

# --- CONFIGURE NGINX ---
rm -f /etc/nginx/sites-enabled/default
curl -fsSL "$REPO_BASE/nginx/wordpress.conf" -o /etc/nginx/sites-available/wordpress
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# --- FINAL RESTART ---
systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx
systemctl restart amazon-cloudwatch-agent

echo "User data script completed successfully." | tee -a /etc/logs/user-data.log
