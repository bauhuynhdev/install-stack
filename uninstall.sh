#!/bin/bash

remove_nginx() {
  echo "====================================="
  echo "Removing Nginx..."
  yum remove -y nginx
  rm -f /etc/yum.repos.d/nginx.repo
  echo "====================================="
}

remove_php() {
  echo "====================================="
  echo "Removing PHP..."
  yum remove -y php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pgsql php-redis
  echo "====================================="
}

remove_composer() {
  echo "====================================="
  echo "Removing Composer..."
  rm -f /usr/local/bin/composer
  echo "====================================="
}

remove_node() {
  echo "====================================="
  echo "Removing Nodejs..."
  npm uninstall -g yarn
  yum remove -y nodejs
  echo "====================================="
}

remove_postgres() {
  echo "====================================="
  echo "Removing Postgres..."
  yum remove -y postgres\*
  echo "====================================="
}

remove_redis() {
  echo "====================================="
  echo "Removing Redis..."
  yum remove -y redis
  echo "====================================="
}

main() {
  remove_nginx
  remove_php
  remove_composer
  remove_node
  remove_postgres
  remove_redis
}

main
