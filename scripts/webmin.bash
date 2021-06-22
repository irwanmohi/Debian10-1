#!/usr/bin/env bash

RED="\033[31;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
BLUE="\033[34;1m"
PURPLE="\033[35;1m"
CYAN="\033[36;1m"
PLAIN="\033[0m"

ipaddr=$( ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1 )

until [[ $YESNO =~ (y|n) ]]; do
  read -rp "Do you want to continue? [y/n]: " YESNO
done
if [[ ! $YESNO =~ ^[Yy]$ ]] ; then
  echo "Goodbye..." && exit
fi

wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'

echo -n "Installing webmin package"
apt-get -qq update &>/dev/null
apt-get -y -qq install webmin &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo ""
echo -e "${GREEN}Congratulation, we are done with webmin setup${PLAIN}"
echo ""
echo "=============================================="
echo -e "${CYAN}[ WEBMIN DETAIL ]${PLAIN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Status:${PLAIN} ${GREEN}Started & Enabled${PLAIN}"
echo -e "${YELLOW}Hostname:${PLAIN} ${GREEN}cybertize.tk${PLAIN}"
echo -e "${YELLOW}Ipaddress:${PLAIN} ${GREEN}$ipaddr${PLAIN}"
echo -e "${YELLOW}Ports:${PLAIN} ${GREEN}10000${PLAIN}"
echo "=============================================="
