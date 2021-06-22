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
  echo -e "${RED}Goodbye...${PLAIN}" && exit
fi

echo -ne "${CYAN}Installing Stunnel package${PLAIN}"
apt-get -qq update &>/dev/null
apt-get -y -qq install stunnel &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

openssl req -new -x509 -days 365 -nodes \
-subj '/C=MY/ST=Sabah/L=Tawau/O="Cybertize Devel"/OU="Stunnel Services"/CN=cybertize' \
-out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &>/dev/null

# /etc/stunnel/stunnel.conf
echo 'pid = /var/run/stunnel4/stunnel4.pid
output = /var/log/stunnel4/stunnel.log
cert = /etc/stunnel/stunnel.pem
debug = 4
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 13564
connect = 127.0.0.1:8695

[openvpn]
accept = 27991
connect = 127.0.0.1:6545

[shadowsocks-libev]
accept = 36162
connect = 127.0.0.1:2426

[squid]
accept = 40502
connect = 127.0.0.1:4613' > /etc/stunnel/stunnel.conf

# /etc/default/stunnel
echo 'ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
PPP_RESTART=0
RLIMITS=""' > /etc/default/stunnel4

echo ""
echo -e "${SUCCESS}Congratulation, we are done with stunnel setup${PLAIN}"
echo ""
echo "=============================================="
echo -e "${CYAN}[ STUNNEL DETAIL ]${CYAN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Status:${PLAIN} ${GREEN}Started & Enabled${PLAIN}"
echo -e "${YELLOW}Dropbear:${PLAIN} ${GREEN}8695${PLAIN}"
echo -e "${YELLOW}OpenVPN:${PLAIN} ${GREEN}6545${PLAIN}"
echo -e "${YELLOW}SS-Libev:${PLAIN} ${GREEN}2426${PLAIN}"
echo "=============================================="
