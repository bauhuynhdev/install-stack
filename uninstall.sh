#!/bin/bash

LOG_FILE="$0.log"

remove_nginx() {
  echo "Removing Nginx..." >>"$LOG_FILE"
  yum remove -y nginx
  rm -f /etc/yum.repos.d/nginx.repo
}

remove_php() {
  echo "Removing PHP..." >>"$LOG_FILE"
  yum remove -y php\*
}

remove_composer() {
  echo "Removing Composer..." >>"$LOG_FILE"
  rm -f /usr/local/bin/composer
}

remove_node() {
  echo "Removing Nodejs..." >>"$LOG_FILE"
  npm uninstall -g yarn
  yum remove -y nodejs
}

remove_postgres() {
  echo "Removing Postgres..." >>"$LOG_FILE"
  yum remove -y postgres\*
}

remove_redis() {
  echo "Removing Redis..." >>"$LOG_FILE"
  yum remove -y redis
}

create_log_file() {
  touch "$LOG_FILE"
  cat /dev/null >"$LOG_FILE"
}

main() {
  create_log_file
  remove_nginx
  remove_php
  remove_composer
  remove_node
  remove_postgres
  remove_redis
  echo "Check $LOG_FILE"
}

main
