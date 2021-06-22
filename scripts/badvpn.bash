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

echo -n "Installing badvpn package"
wget -q "https://github.com/ambrop72/badvpn/archive/refs/tags/1.999.130.tar.gz" &>/dev/null
tar xzf 1.999.130.tar.gz && cd badvpn-1.999.130
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1 -DBUILD_UDPGW=1
make install
echo -e "[ ${GREEN}DONE${PLAIN} ]"
mv /usr/local/bin/badvpn-udpgw /usr/sbin/
mv /usr/local/bin/badvpn-tun2socks /usr/sbin/

screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
# echo '@reboot /usr/sbin/badvpn-udpgw --listen-addr 127.0.0.1:7300' >> /etc/crontab

echo ""
echo -e "${GREEN}Congratulation, we are done with dropbear setup${PLAIN}"
echo ""
echo "=============================================="
echo -e "${CYAN}[ BADVPN DETAIL ]${PLAIN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Status:${PLAIN} ${GREEN}Started & Enabled${PLAIN}"
echo -e "${YELLOW}Ipaddress:${PLAIN} ${GREEN}127.0.0.1${PLAIN}"
echo -e "${YELLOW}Ports:${PLAIN} ${GREEN}7300${PLAIN}"
echo "=============================================="
