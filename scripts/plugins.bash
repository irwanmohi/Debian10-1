#!/usr/bin/env bash

RED="\033[31;1m"
GREEN="\033[32;1m"
PLAIN="\033[0m"

if [ "$EUID" -ne 0 ]; then
  echo -e "[${RED}●${PLAIN}] Script needs to be run as root" && exit
fi

if readlink /proc/$$/exe | grep -qs "dash"; then
  echo -e "[${RED}●${PLAIN}] Script needs to be run with bash" && exit
fi

echo -n "Copy plugin files to /usr/local/bin"
cp /root/Debian10-main/plugins/menu /usr/local/bin/
cp /root/Debian10-main/plugins/accounts/* /usr/local/bin/
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Enable execuution mod for root user"
chmod u+x /usr/local/bin/*
echo -e "[ ${GREEN}DONE${PLAIN} ]"
