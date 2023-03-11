#!/bin/bash

install_common() {
  yum update -y
  yum install -y epel-release yum-utils zip unzip net-tools curl wget gcc-c++ make nano openssl htop
  yum update -y
  echo "----------------------------------- Common installed -----------------------------------"
}

install_nginx() {
  # shellcheck disable=SC2046
  if [ $(command -v nginx) ]; then
    echo "----------------------------------- Nginx installed -----------------------------------"
  else
    echo "----------------------------------- Installing Nginx -----------------------------------"
    curl https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/nginx.repo -L -o /etc/yum.repos.d/nginx.repo
    yum install -y nginx
    echo "----------------------------------- Nginx installed -----------------------------------"
  fi
}

install_php() {
  # shellcheck disable=SC2046
  if [ $(command -v php) ]; then
    echo "----------------------------------- PHP installed -----------------------------------"
  else
    echo "----------------------------------- Installing PHP -----------------------------------"
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum --enablerepo=remi-php74 install -y php php-cli php-fpm php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-mysql php-redis -y
    echo "----------------------------------- PHP installed -----------------------------------"
  fi
}

install_composer() {
  # shellcheck disable=SC2046
  if [ $(command -v composer) ]; then
    echo "----------------------------------- Composer installed -----------------------------------"
  else
    echo "----------------------------------- Installing Composer -----------------------------------"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
    echo "----------------------------------- Composer installed -----------------------------------"
  fi
}

install_nodejs_npm_pm2() {
  # shellcheck disable=SC2046
  if [ $(command -v node) ]; then
    echo "----------------------------------- Nodejs, NPM and PM2 installed -----------------------------------"
  else
    echo "----------------------------------- Installing Nodejs, NPM and PM2 -----------------------------------"
    curl -sL https://rpm.nodesource.com/setup_14.x | bash -
    yum install -y nodejs
    npm install -g yarn pm2
    echo "----------------------------------- Nodejs, NPM and PM2 installed -----------------------------------"
  fi
}

install_postgres() {
  # shellcheck disable=SC2046
  if [ $(command -v psql) ]; then
    echo "----------------------------------- Postgres installed -----------------------------------"
  else
    echo "----------------------------------- Installing Postgres -----------------------------------"
    yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/pgdg-redhat-repo-latest.noarch.rpm
    yum install -y postgresql13-server
    /usr/pgsql-13/bin/postgresql-13-setup initdb
    echo "----------------------------------- Postgres installed -----------------------------------"
  fi
}

install_mysql() {
  # shellcheck disable=SC2046
  if [ $(command -v mysql) ]; then
    echo "----------------------------------- MySQL installed -----------------------------------"
  else
    echo "----------------------------------- Installing MySQL -----------------------------------"
    rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
    sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
    yum --enablerepo=mysql80-community install mysql-community-server -y
    echo "----------------------------------- MySQL installed -----------------------------------"
  fi
}

install_redis() {
  # shellcheck disable=SC2046
  if [ $(command -v redis-cli) ]; then
    echo "----------------------------------- Redis installed -----------------------------------"
  else
    echo "----------------------------------- Installing Redis -----------------------------------"
    # Installed repo redis in PHP
    yum --enablerepo=remi install redis -y
    echo "----------------------------------- Redis installed -----------------------------------"
  fi
}

enable_and_start_services() {
  yum update -y
  # shellcheck disable=SC2046
  if [ $(command -v systemctl) ]; then
    systemctl enable --now nginx
    systemctl enable --now php-fpm
    systemctl enable --now mysqld
    echo "----------------------------------- MySQL temporary password -----------------------------------"
    grep "A temporary password" /var/log/mysqld.log
    echo "You will need run this command to change password: mysql_secure_installation"
    echo "------------------------------------------------------------------------------------------------"
    systemctl enable --now redis
  fi
  echo "----------------------------------- Services enabled and started -----------------------------------"
}

main() {
  if [ -f /etc/centos-release ]; then
    if grep -q "CentOS Linux release 7" /etc/centos-release; then
      install_common
      install_nginx
      install_php
      install_mysql
      install_composer
      install_nodejs_npm_pm2
      install_redis
      enable_and_start_services
    else
      echo "- This script only support CentOS 7."
    fi
  else
    echo "- This script only support CentOS 7."
  fi
}

main
