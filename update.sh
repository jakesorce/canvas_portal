#!/bin/bash

git pull --rebase
bundle update

if [ ! -f ../files/generating.txt ];
then
  sudo killall ruby
  sudo killall ruby
  sudo killall ruby
  service sinatra-server start
  echo -e "\e[00;32m[UPDATE SUCCESSFUL]\e[00m"
else
  echo -e "\e[00;31m[UPDATE FAILED]\e[00m generating.txt file exists"
fi
