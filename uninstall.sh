#!/bin/bash

uninstall_git() {
  # shellcheck disable=SC2046
  if ! [ $(command -v git) ]; then
    echo "*********************************** Removing Git ***********************************"
    yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
    yum install -y git
  fi
  echo "*********************************** Git removed ***********************************"
}

uninstall_nginx() {
  # shellcheck disable=SC2046
  if [ $(command -v nginx) ]; then
    echo "*********************************** Removing Nginx ***********************************"
    systemctl stop nginx
    systemctl disable nginx
    yum remove -y nginx
    rm -rf /etc/nginx
    rm -rf /var/log/nginx
    rm -rf /var/cache/nginx
  fi
  echo "*********************************** Nginx removed ***********************************"
}

uninstall_php() {
  # shellcheck disable=SC2046
  if [ $(command -v php) ]; then
    echo "*********************************** Removing PHP ***********************************"
    systemctl stop php-fpm
    systemctl disable php-fpm
    yum remove -y php php-cli php-fpm php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-mysql php-redis -y
    rm -rf /etc/php
    rm -rf /var/log/php
    rm -rf /var/cache/php
    rm -rf /etc/php-fpm.d
    rm -rf /var/lib/php
    rm -rf /var/log/php-fpm
  fi
  echo "*********************************** PHP removed ***********************************"
}

uninstall_composer() {
  # shellcheck disable=SC2046
  if [ $(command -v composer) ]; then
    echo "*********************************** Removing Composer ***********************************"
    rm -rf /usr/local/bin/composer
    rm -rf /usr/local/composer
    rm -rf ~/.composer
  fi
  echo "*********************************** Composer removed ***********************************"
}

uninstall_nodejs_npm_pm2() {
  # shellcheck disable=SC2046
  if ! [ $(command -v node) ]; then
    echo "*********************************** Removing Nodejs, NPM and PM2 ***********************************"
    curl -sL https://rpm.nodesource.com/setup_14.x | bash -
    yum install -y nodejs
    npm install -g yarn pm2
  fi
  echo "*********************************** Nodejs, NPM and PM2 removed ***********************************"
}

uninstall_postgres() {
  # shellcheck disable=SC2046
  if ! [ $(command -v psql) ]; then
    echo "*********************************** Removing Postgres ***********************************"
    yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/pgdg-redhat-repo-latest.noarch.rpm
    yum install -y postgresql13-server
    /usr/pgsql-13/bin/postgresql-13-setup initdb
  fi
  echo "*********************************** Postgres removed ***********************************"
}

uninstall_mysql() {
  # shellcheck disable=SC2046
  if ! [ $(command -v mysql) ]; then
    echo "*********************************** Removing MySQL ***********************************"
    rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
    sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
    yum --enablerepo=mysql80-community install mysql-community-server -y
  fi
  echo "*********************************** MySQL removed ***********************************"
}

uninstall_redis() {
  # shellcheck disable=SC2046
  if ! [ $(command -v redis-cli) ]; then
    echo "*********************************** Removing Redis ***********************************"
    # removed repo redis in PHP
    yum --enablerepo=remi install redis -y
  fi
  echo "*********************************** Redis removed ***********************************"
}

uninstall_firewall() {
  echo "*********************************** Removing Firewall ***********************************"
  systemctl stop firewalld
  systemctl disable firewalld
  yum remove firewalld -y
  rm -rf /etc/firewalld
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
      uninstall_firewall
      uninstall_git
      uninstall_nginx
      uninstall_php
      uninstall_mysql
      uninstall_composer
      uninstall_nodejs_npm_pm2
      uninstall_redis
      final
    else
      echo "* This script only support CentOS 7. *"
    fi
  else
    echo "* This script only support CentOS 7. *"
  fi
}

main
