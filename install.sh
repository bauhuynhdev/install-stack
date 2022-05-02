#!/bin/bash

install_common() {
  echo "====================================="
  echo "Run update and install base packages"
  echo "====================================="
  yum update -y
  yum install -y epel-release yum-utils zip unzip gcc-c++ make nano openssl
}

install_nginx() {
  echo "====================================="
  echo "Checking Nginx..."
  if command -v nginx >/dev/null; then
    echo "Installed Nginx."
  else
    echo "Installing Nginx..."
    curl https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/nginx.repo -L -o /etc/yum.repos.d/nginx.repo
    yum install -y nginx-1.20.2
    echo "Installed Nginx."
  fi
  echo "====================================="
}

install_php() {
  echo "====================================="
  echo "Checking PHP..."
  if command -v php >/dev/null; then
    echo "Installed PHP."
  else
    echo "Installing PHP..."
    yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/remi-release-7.rpm
    yum --enablerepo=remi-php74 install -y php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pgsql php-redis
    echo "Installed PHP."
  fi
  echo "====================================="
}

install_composer() {
  echo "====================================="
  echo "Checking Composer..."
  if command -v /usr/local/bin/composer >/dev/null; then
    echo "Installed Composer."
  else
    echo "Installing Composer..."
    php -r "copy('https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/composer-setup.php', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=2.2.9
    php -r "unlink('composer-setup.php');"
    echo "Installed Composer."
  fi
  echo "====================================="
}

install_node() {
  echo "====================================="
  echo "Checking Nodejs..."
  if command -v node >/dev/null; then
    echo "Installed Nodejs."
  else
    echo "Installing Nodejs..."
    curl -L https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/setup_14.x | bash -
    yum install -y nodejs
    npm install -g yarn
    echo "Installed Nodejs."
  fi
  echo "====================================="
}

install_postgres() {
  echo "====================================="
  echo "Checking Postgres..."
  if systemctl --all --type service | grep -q "postgresql-13.service"; then
    echo "Installed Postgres."
  else
    echo "Installing Postgres..."
    yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/pgdg-redhat-repo-latest.noarch.rpm
    yum install -y postgresql13-server
    /usr/pgsql-13/bin/postgresql-13-setup initdb
    echo "Installed Postgres."
  fi
  echo "====================================="
}

install_redis() {
  echo "====================================="
  echo "Checking Redis..."
  if systemctl --all --type service | grep -q "redis.service"; then
    echo "Installed Redis."
  else
    echo "Installing Redis..."
    # Installed repo redis in PHP
    yum --enablerepo=remi install redis -y
    /usr/pgsql-13/bin/postgresql-13-setup initdb
    echo "Installed Redis."
  fi
  echo "====================================="
}

enable_services() {
  echo "====================================="
  echo "Enabling services..."
  if command -v systemctl >/dev/null; then
    systemctl enable --now nginx
    systemctl enable --now php-fpm
    systemctl enable --now postgresql-13
    systemctl enable --now redis
  fi
  echo "====================================="
}

main() {
  install_common
  install_nginx
  install_php
  install_composer
  install_node
  install_postgres
  install_redis
  enable_services
}

main
