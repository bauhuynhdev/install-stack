#!/bin/bash

install_common() {
  echo "*********************************** Installing Common ***********************************"
  sudo yum update -y
  sudo yum install -y epel-release yum-utils
  sudo yum update -y
  sudo yum install -y zip unzip net-tools curl wget gcc-c++ make nano openssl htop
  echo "*********************************** Common installed ***********************************"
}

install_git() {
  # shellcheck disable=SC2046
  if ! [ $(command -v git) ]; then
    echo "*********************************** Installing Git ***********************************"
    sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
    sudo yum install -y git
  fi
  echo "*********************************** Git installed ***********************************"
}

install_nginx() {
  # shellcheck disable=SC2046
  if ! [ $(command -v nginx) ]; then
    echo "*********************************** Installing Nginx ***********************************"
    sudo curl https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/nginx.repo -L -o /etc/yum.repos.d/nginx.repo
    sudo yum install -y nginx
  fi
  echo "*********************************** Nginx installed ***********************************"
}

install_php() {
  # shellcheck disable=SC2046
  if ! [ $(command -v php) ]; then
    echo "*********************************** Installing PHP ***********************************"
    sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    sudo yum --enablerepo=remi-php74 install -y php php-cli php-fpm php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-mysql php-redis -y
  fi
  echo "*********************************** PHP installed ***********************************"
}

install_composer() {
  # shellcheck disable=SC2046
  if ! [ $(command -v composer) ]; then
    echo "*********************************** Installing Composer ***********************************"
    sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    sudo php -r "unlink('composer-setup.php');"
  fi
  echo "*********************************** Composer installed ***********************************"
}

install_nodejs_npm_pm2() {
  # shellcheck disable=SC2046
  if ! [ $(command -v node) ]; then
    echo "*********************************** Installing Nodejs, NPM and PM2 ***********************************"
    sudo curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
    sudo yum install -y nodejs
    sudo npm install -g yarn pm2
  fi
  echo "*********************************** Nodejs, NPM and PM2 installed ***********************************"
}

install_postgres() {
  # shellcheck disable=SC2046
  if ! [ $(command -v psql) ]; then
    echo "*********************************** Installing Postgres ***********************************"
    sudo yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/pgdg-redhat-repo-latest.noarch.rpm
    sudo yum install -y postgresql13-server
    sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
  fi
  echo "*********************************** Postgres installed ***********************************"
}

install_mysql() {
  # shellcheck disable=SC2046
  if ! [ $(command -v mysql) ]; then
    echo "*********************************** Installing MySQL ***********************************"
    sudo rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
    sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
    sudo yum --enablerepo=mysql80-community install mysql-community-server -y
  fi
  echo "*********************************** MySQL installed ***********************************"
}

install_redis() {
  # shellcheck disable=SC2046
  if ! [ $(command -v redis-cli) ]; then
    echo "*********************************** Installing Redis ***********************************"
    # Installed repo redis in PHP
    sudo yum --enablerepo=remi install redis -y
  fi
  echo "*********************************** Redis installed ***********************************"
}

install_firewall() {
  echo "*********************************** Installing Firewall ***********************************"
  sudo yum install -y firewalld
  sudo systemctl enable --now firewalld
  echo "*********************************** Firewall installed ***********************************"
}

final() {
  sudo yum update -y
  #  echo "*********************************** Enabling and starting services ***********************************"
  # shellcheck disable=SC2046
  #  if [ $(command -v systemctl) ]; then
  #    if ! [ "$(systemctl is-active nginx)" = "active" ]; then
  #      echo "*********************************** Starting Nginx ***********************************"
  #      systemctl enable --now nginx
  #    fi
  #    if ! [ "$(systemctl is-active php-fpm)" = "active" ]; then
  #      echo "*********************************** Starting PHP-FPM ***********************************"
  #      systemctl enable --now php-fpm
  #    fi
  #    if ! [ "$(systemctl is-active mysqld)" = "active" ]; then
  #      echo "*********************************** Starting MySQL ***********************************"
  #      systemctl enable --now mysqld
  #    fi
  #    if ! [ "$(systemctl is-active redis)" = "active" ]; then
  #      echo "*********************************** Starting Redis ***********************************"
  #      systemctl enable --now redis
  #    fi
  #  fi
  #  echo "*********************************** Services enabled and started ***********************************"
  echo "*********************************** MySQL temporary password ***********************************"
  sudo grep "A temporary password" /var/log/mysqld.log
  echo "If install mysql the first time, please run this command: mysql_secure_installation"
  sudo firewall-cmd --permanent --add-service=http
  echo "*********************************** HTTP port enabled ***********************************"
  sudo firewall-cmd --permanent --add-service=https
  echo "*********************************** HTTPS port enabled ***********************************"
  sudo firewall-cmd --reload
  echo "*********************************** Reload firewall ***********************************"
  echo "*********************************** Basic started ***********************************"
  echo "systemctl enable --now nginx"
  echo "systemctl enable --now php-fpm"
  echo "systemctl enable --now mysqld"
  echo "systemctl enable --now redis"
  echo "*********************************** Basic stopped ***********************************"
}

main() {
  if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
  fi
  if [ -f /etc/centos-release ]; then
    if grep -q "CentOS Linux release 7" /etc/centos-release; then
      install_common
      install_firewall
      install_git
      install_nginx
      install_php
      install_mysql
      install_composer
      install_nodejs_npm_pm2
      install_redis
      final
    else
      echo "* This script only support CentOS 7. *"
    fi
  else
    echo "* This script only support CentOS 7. *"
  fi
}

main
