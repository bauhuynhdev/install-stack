#!/bin/bash

main() {
  download_and_unzip
  final
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
