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

echo -n "Installing Dropbear package"
apt-get -qq update &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get -y -qq install dropbear &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Backup default config and create new config file for dropbear"
cp /etc/default/dropbear /etc/default/dropbear.bak
echo 'NO_START=0
DROPBEAR_PORT=5968
DROPBEAR_EXTRA_ARGS="-p 8695"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536' > /etc/default/dropbear
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo ""
echo -e "${GREEN}Congratulation, we are done with dropbear setup${PLAIN}"
echo ""
echo "=============================================="
echo -e "${CYAN}[ DROPBEAR DETAIL ]${PLAIN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Status:${PLAIN} ${GREEN}Started & Enabled${PLAIN}"
echo -e "${YELLOW}Hostname:${PLAIN} ${GREEN}cybertize.tk${PLAIN}"
echo -e "${YELLOW}Ipaddress:${PLAIN} ${GREEN}$ipaddr${PLAIN}"
echo -e "${YELLOW}Ports:${PLAIN} ${GREEN}5968 & 8695(TLS)${PLAIN}"
echo "=============================================="
