#!/bin/bash

main() {
  remove_old
  download
  final
}

remove_old() {
  echo "*********************************** Removing old ***********************************"
  sudo rm -rf /tmp/Geekbench-*
  echo "*********************************** Removed old ***********************************"
}

unzip() {
  echo "*********************************** Unzipping ***********************************"
  sudo tar -zxvf /tmp/Geekbench-5.5.1-Linux.tar.gz -C /tmp
  echo "*********************************** Unzipped ***********************************"
}

download() {
  echo "*********************************** Downloading ***********************************"
  sudo curl -sL https://cdn.geekbench.com/Geekbench-5.5.1-Linux.tar.gz -o /tmp/Geekbench-5.5.1-Linux.tar.gz
  echo "*********************************** Downloaded ***********************************"
}

final() {
  echo "*********************************** Running ***********************************"
  sudo /tmp/Geekbench-5.5.1-Linux/geekbench5
  echo "*********************************** Done ***********************************"
}

main
