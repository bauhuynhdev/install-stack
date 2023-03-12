#!/bin/bash

install_common() {
  echo "*********************************** Installing Common ***********************************"
  yum update -y
  yum install -y epel-release yum-utils zip unzip net-tools curl wget gcc-c++ make nano openssl htop
  yum update -y
  echo "*********************************** Common installed ***********************************"
}

install_git() {
  # shellcheck disable=SC2046
  if ! [ $(command -v git) ]; then
    echo "*********************************** Installing Git ***********************************"
    yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
    yum install -y git
  fi
  echo "*********************************** Git installed ***********************************"
}

install_nginx() {
  # shellcheck disable=SC2046
  if ! [ $(command -v nginx) ]; then
    echo "*********************************** Installing Nginx ***********************************"
    curl https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/nginx.repo -L -o /etc/yum.repos.d/nginx.repo
    yum install -y nginx
  fi
  echo "*********************************** Nginx installed ***********************************"
}

install_php() {
  # shellcheck disable=SC2046
  if ! [ $(command -v php) ]; then
    echo "*********************************** Installing PHP ***********************************"
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum --enablerepo=remi-php74 install -y php php-cli php-fpm php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-mysql php-redis -y
  fi
  echo "*********************************** PHP installed ***********************************"
}

install_composer() {
  # shellcheck disable=SC2046
  if ! [ $(command -v composer) ]; then
    echo "*********************************** Installing Composer ***********************************"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
  fi
  echo "*********************************** Composer installed ***********************************"
}

install_nodejs_npm_pm2() {
  # shellcheck disable=SC2046
  if ! [ $(command -v node) ]; then
    echo "*********************************** Installing Nodejs, NPM and PM2 ***********************************"
    curl -sL https://rpm.nodesource.com/setup_14.x | bash -
    yum install -y nodejs
    npm install -g yarn pm2
  fi
  echo "*********************************** Nodejs, NPM and PM2 installed ***********************************"
}

install_postgres() {
  # shellcheck disable=SC2046
  if ! [ $(command -v psql) ]; then
    echo "*********************************** Installing Postgres ***********************************"
    yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/pgdg-redhat-repo-latest.noarch.rpm
    yum install -y postgresql13-server
    /usr/pgsql-13/bin/postgresql-13-setup initdb
  fi
  echo "*********************************** Postgres installed ***********************************"
}

install_mysql() {
  # shellcheck disable=SC2046
  if ! [ $(command -v mysql) ]; then
    echo "*********************************** Installing MySQL ***********************************"
    rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
    sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
    yum --enablerepo=mysql80-community install mysql-community-server -y
  fi
  echo "*********************************** MySQL installed ***********************************"
}

install_redis() {
  # shellcheck disable=SC2046
  if ! [ $(command -v redis-cli) ]; then
    echo "*********************************** Installing Redis ***********************************"
    # Installed repo redis in PHP
    yum --enablerepo=remi install redis -y
  fi
  echo "*********************************** Redis installed ***********************************"
}

install_firewall() {
  echo "*********************************** Installing Firewall ***********************************"
  yum install -y firewalld
  systemctl enable --now firewalld
  echo "*********************************** Firewall installed ***********************************"
}

final() {
  yum update -y
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
  grep "A temporary password" /var/log/mysqld.log
  echo "If install mysql the first time, please run this command: mysql_secure_installation"
  firewall-cmd --permanent --add-service=http
  echo "*********************************** HTTP port enabled ***********************************"
  firewall-cmd --permanent --add-service=https
  echo "*********************************** HTTPS port enabled ***********************************"
  firewall-cmd --reload
  echo "*********************************** Reload firewall ***********************************"
  echo "*********************************** Basic started ***********************************"
  echo "systemctl enable --now nginx"
  echo "systemctl enable --now php-fpm"
  echo "systemctl enable --now mysqld"
  echo "systemctl enable --now redis"
  echo "*********************************** Basic stopped ***********************************"
}

main() {
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
