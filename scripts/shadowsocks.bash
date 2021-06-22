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

echo -n "Installing Shadowsocks-libev package"
apt-get -qq update &>/dev/null
apt-get -y -qq install shadowsocks-libev &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo "{
  "server":["::1", "127.0.0.1"],
  "mode":"tcp_and_udp",
  "server_port":6242,
  "local_port":1080,
  "password":"2021.Cybertize",
  "timeout":60,
  "method":"chacha20-ietf-poly1305"
}" > /etc/shadowsocks-libev/config.json

echo ""
echo -e "${GREEN}Congratulation, we are done with stunnel setup${PLAIN}"
echo ""
echo "=============================================="
echo -e "${CYAN}[ SS-LIBEV DETAIL ]${PLAIN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Status:${YELLOW} ${GREEN}Started & Enabled${PLAIN}"
echo -e "${YELLOW}Hostname:${YELLOW} ${GREEN}cybertize.tk${PLAIN}"
echo -e "${YELLOW}Ipaddress:${YELLOW} ${GREEN}$ipaddr${PLAIN}"
echo -e "${YELLOW}Ports:${YELLOW} ${GREEN}6242 & 2426(TLS)${PLAIN}"
echo "=============================================="
