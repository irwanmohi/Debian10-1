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

echo -n "Installing Squid package"
apt-get -qq update &>/dev/null
apt-get -y -qq install squid &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

# /etc/squid/squid.conf
echo "# CYBERTIZE SQUID CONFIG
# ----------------------------
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16

acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl cybertize dst $ipaddr/24

http_access allow cybertize
http_access allow localnet
http_access allow localhost
http_access allow manager localhost
http_access deny manager
http_access deny all

http_port 4613
http_port 3164

cache deny all
access_log none
cache_store_log none
cache_log /dev/null
hierarchy_stoplist cgi-bin ?

refresh_pattern ^ftp: 1440 20%	10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0	0% 0
refresh_pattern . 0	20%	4320
visible_hostname proxy.cybertize.tk" > /etc/squid/squid.conf

echo ""
echo "Congratulation, we are done with squid setup"
echo ""
echo "============================================"
echo "[ SQUID DETAIL ]"
echo "--------------------------------------------"
echo "Status: Enabled"
echo "Ipaddress: $ipaddr"
echo "Ports: 3128 & 8080"
echo "============================================"

echo ""
echo -e "${GREEN}Congratulation, we are done with squid setup${PLAIN}"
echo ""
echo "=============================================="
echo -e "${CYAN}[ SQUID DETAIL ]${PLAIN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Status:${YELLOW} ${GREEN}Started & Enabled${PLAIN}"
echo -e "${YELLOW}Ipaddress:${YELLOW} ${GREEN}$ipaddr${PLAIN}"
echo -e "${YELLOW}Ports:${YELLOW} ${GREEN}6242 & 2426(TLS)${PLAIN}"
echo "=============================================="
