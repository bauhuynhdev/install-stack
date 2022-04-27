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
    cat >/etc/yum.repos.d/nginx.repo <<'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=https://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
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
    yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
    yum-config-manager --enable remi-php74 -y
    yum install -y php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pgsql php-redis
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
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
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
    curl -fsSL https://rpm.nodesource.com/setup_14.x | bash -
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
    yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
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
    yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
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
