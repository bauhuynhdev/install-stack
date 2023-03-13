#!/bin/bash

main() {
  remove_old
  download_and_unzip
  final
}

remove_old() {
  echo "*********************************** Removing old ***********************************"
  sudo rm -rf /tmp/Geekbench-*
  echo "*********************************** Removed old ***********************************"
}

download_and_unzip() {
  echo "*********************************** Downloading ***********************************"
  sudo curl -sL https://cdn.geekbench.com/Geekbench-5.5.1-Linux.tar.gz -o /tmp/Geekbench-5.5.1-Linux.tar.gz
  echo "*********************************** Downloaded ***********************************"
  echo "*********************************** Unzipping ***********************************"
  sudo tar -zxvf /tmp/Geekbench-5.5.1-Linux.tar.gz -C /tmp
  echo "*********************************** Unzipped ***********************************"
}

final() {
  echo "*********************************** Running ***********************************"
  sudo /tmp/Geekbench-5.5.1-Linux/geekbench5
  echo "*********************************** Done ***********************************"
}

main