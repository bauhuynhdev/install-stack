#!/bin/bash

LOG_FILE="$0.log"

install_common() {
  yum update -y
  yum install -y epel-release yum-utils zip unzip gcc-c++ make nano openssl
  echo "Run update and install base packages." >>"$LOG_FILE"
}

install_nginx() {
  if command -v nginx >/dev/null; then
    echo "Installed Nginx." >>"$LOG_FILE"
  else
    echo "Installing Nginx..." >>"$LOG_FILE"
    curl https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/nginx.repo -L -o /etc/yum.repos.d/nginx.repo
    yum install -y nginx-1.20.2
    echo "Installed Nginx." >>"$LOG_FILE"
  fi
}

install_php() {
  if command -v php >/dev/null; then
    echo "Installed PHP." >>"$LOG_FILE"
  else
    echo "Installing PHP..." >>"$LOG_FILE"
    yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/remi-release-7.rpm
    yum --enablerepo=remi-php74 install -y php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pgsql php-redis
    echo "Installed PHP." >>"$LOG_FILE"
  fi
}

install_composer() {
  if command -v /usr/local/bin/composer >/dev/null; then
    echo "Installed Composer." >>"$LOG_FILE"
  else
    echo "Installing Composer..." >>"$LOG_FILE"
    php -r "copy('https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/composer-setup.php', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=2.2.9
    php -r "unlink('composer-setup.php');"
    echo "Installed Composer." >>"$LOG_FILE"
  fi
}

install_node() {
  if command -v node >/dev/null; then
    echo "Installed Nodejs." >>"$LOG_FILE"
  else
    echo "Installing Nodejs..." >>"$LOG_FILE"
    curl -L https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/setup_14.x | bash -
    yum install -y nodejs
    npm install -g yarn
    echo "Installed Nodejs." >>"$LOG_FILE"
  fi
}

install_postgres() {
  if systemctl --all --type service | grep -q "postgresql-13.service"; then
    echo "Installed Postgres." >>"$LOG_FILE"
  else
    echo "Installing Postgres..." >>"$LOG_FILE"
    yum install -y https://raw.githubusercontent.com/bauhuynhdev/linux-repo/master/pgdg-redhat-repo-latest.noarch.rpm
    yum install -y postgresql13-server
    /usr/pgsql-13/bin/postgresql-13-setup initdb
    echo "Installed Postgres." >>"$LOG_FILE"
  fi
}

install_redis() {
  if systemctl --all --type service | grep -q "redis.service"; then
    echo "Installed Redis." >>"$LOG_FILE"
  else
    echo "Installing Redis..." >>"$LOG_FILE"
    # Installed repo redis in PHP
    yum --enablerepo=remi install redis -y
    /usr/pgsql-13/bin/postgresql-13-setup initdb
    echo "Installed Redis." >>"$LOG_FILE"
  fi
}

enable_services() {
  if command -v systemctl >/dev/null; then
    systemctl enable --now nginx
    systemctl enable --now php-fpm
    systemctl enable --now postgresql-13
    systemctl enable --now redis
  fi
  echo "Enabled services" >>"$LOG_FILE"
}

create_log_file() {
  touch "$LOG_FILE"
  cat /dev/null >"$LOG_FILE"
}

main() {
  create_log_file
  install_common
  install_nginx
  install_php
  install_composer
  install_node
  install_postgres
  install_redis
  enable_services
  echo "Check $LOG_FILE"
}

main
