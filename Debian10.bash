#!/usr/bin/env bash

. /etc/os-release

RED="\033[31;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
BLUE="\033[34;1m"
PURPLE="\033[35;1m"
CYAN="\033[36;1m"
PLAIN="\033[0m"

ipaddr=$( ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1 )

echo -e "${CYAN}----------------------------------------------------------------${PLAIN}"
echo -e "${PURPLE}'||'  '|' '||''|.   .|'''.|${PLAIN}  ${BLUE}+-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+${PLAIN}"
echo -e "${PURPLE} '|.  .'   ||   ||  ||..  '${PLAIN}  ${BLUE}|C| |Y| |B| |E| |R| |T| |I| |Z| |E|${PLAIN}"
echo -e "${PURPLE}  ||  |    ||...|'   ''|||.${PLAIN}  ${BLUE}+-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+${PLAIN}"
echo -e "${PURPLE}   |||     ||      .    '||${PLAIN}  ${GREEN}Created by Doctype${PLAIN}"
echo -e "${PURPLE}    |     .||.      |'...|'${PLAIN}  ${GREEN}Copyright 2021 Cybertize,${PLAIN}"
echo -e "${PURPLE}      Linux Debian-10      ${PLAIN}  ${GREEN}Allright Reserved.${PLAIN}"
echo -e "${CYAN}----------------------------------------------------------------${PLAIN}"
echo ""

until [[ $YESNO =~ (y|n) ]]; do
  read -rp "Do you want to continue? [y/n]: " YESNO
done
if [[ ! $YESNO =~ ^[Yy]$ ]] ; then
  echo -e "[${RED}●${PLAIN}]  Goodbye..." && exit
fi

if [ "$EUID" -ne 0 ]; then
  echo -e "[${RED}●${PLAIN}] Script needs to be run as root" && exit
fi

if [[ $ID == "debian" ]]; then
  if [[ $VERSION_ID -ne 10 ]]; then
    echo -e "[${RED}●${PLAIN}] This script only support Debian 10 only" && exit
  fi
else
  echo -e "[${RED}●${PLAIN}] Please run this scripts on a Debian" && exit
fi

if readlink /proc/$$/exe | grep -qs "dash"; then
  echo -e "[${RED}●${PLAIN}] Script needs to be run with bash" && exit
fi

if [ ! -e /dev/net/tun ]; then
  echo -e "[${RED}●${PLAIN}] You need to enable tun first" && exit
fi

timedatectl set-timezone Asia/Kuala_Lumpur

apt-get -qq update &>/dev/null
apt-get -y -qq upgrade &>/dev/null
apt-get -y -qq install build-essential curl git unzip libtool autoconf automake cmake &>/dev/null
apt-get -y -qq install apt-transport-https software-properties-common &>/dev/null

echo "#!/bin/bash
echo \"----------------------------------------------------------------\"
echo \"'||'  '|' '||''|.   .|'''.|  +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+\"
echo \" '|.  .'   ||   ||  ||..  '  |C| |Y| |B| |E| |R| |T| |I| |Z| |E|\"
echo \"  ||  |    ||...|'   ''|||.  +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+\"
echo \"   |||     ||      .    '||  Created by Doctype\"
echo \"    |     .||.      |'...|'  Copyright 2021 Cybertize,\"
echo \"      Linux Debian-10        Allright Reserved.\"
echo \"----------------------------------------------------------------\"" > /etc/update-motd.d/10-uname
echo "" > /etc/motd

echo "deb http://deb.debian.org/debian/ buster main
deb-src http://deb.debian.org/debian/ buster main
deb http://deb.debian.org/debian/ buster-updates main
deb-src http://deb.debian.org/debian/ buster-updates main
deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main
deb http://mirrors.digitalocean.com/debian buster-backports main contrib non-free
deb-src http://mirrors.digitalocean.com/debian buster-backports main contrib non-free" > /etc/apt/sources.list

# /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv4.ip_forward=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla" > /etc/sysctl.conf
sysctl -p &>/dev/null

# /etc/shells
echo "# /etc/shells: valid login shells
/bin/sh
/bin/bash
/usr/bin/bash
/bin/rbash
/usr/bin/rbash
/bin/dash
/usr/bin/dash
/usr/bin/screen
/bin/false
/usr/bin/false" > /etc/shells

# /etc/issue.net
echo "[[ CYBERTIZE TERMS OF USE ]]

  - NO DDOS
  - NO TORREN
  - NO FLOODING
  - NO BUTEFORCE
  - NO MULTI LOGIN

url: https://cybertize.tk/
email: contact@cybertize.tk
telegram: https://t.me/ndiey" > /etc/issue.net

echo '# ~/.profile: executed by Bourne-compatible login shells.
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

ulimit -n 51200
mesg n || true' > ~/.profile
source ~/.profile

echo "# ~/.bashrc: executed by bash(1) for non-login shells.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

export LS_OPTIONS='--color=auto'
eval \"`dircolors`\"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias la='ls $LS_OPTIONS -a'" > ~/.bashrc
source ~/.bashrc

##
# dropbear package installation & configuration
##
echo -n "Installing Dropbear package..."
apt-get -qq update &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get -y -qq install dropbear &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

# /etc/default/dropbear
echo -n "Create config file for dropbear..."
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

##
# openvpn package installation & configuration
##
echo -n "Installing openvpn package "
apt-get -qq update &>/dev/null
apt-get -y -qq install openvpn &>/dev/null
rm -r /etc/openvpn/server &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create & Generate cert and key for openvpn..."
cd /usr/share/easy-rsa
./easyrsa --batch init-pki &>/dev/null
./easyrsa --batch build-ca nopass &>/dev/null
./easyrsa --batch gen-dh &>/dev/null
./easyrsa --batch build-server-full server nopass &>/dev/null
cp -R /usr/share/easy-rsa/pki /etc/openvpn/
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create config file for openvpn..."
# /etc/openvpn/server.conf
echo "# OVPN SERVER-CUSTOM CONFIG
# ----------------------------
port 5456
proto tcp
dev tun

ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem

verify-client-cert none
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push \"redirect-gateway def1 bypass-dhcp\"
push \"dhcp-option DNS 8.8.8.8\"
push \"dhcp-option DNS 8.8.4.4\"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status status.log
log ovpn.log
verb 3
mute 10
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
username-as-common-name" > /etc/openvpn/server.conf

# customClient.conf - Custom client config file
echo "# OVPN CLIENT-CUSTOM CONFIG
# ----------------------------
client
dev tun
proto tcp
remote $ipaddr 5456
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
verb 3
auth-user-pass

;http-proxy-retry
;http-proxy $ipaddr 6242
;http-proxy-option CUSTOM-HEADER Protocol HTTP/1.1
;http-proxy-option CUSTOM-HEADER Host HOSTNAME" > /etc/openvpn/client/client-custom.conf

echo "" >> /etc/openvpn/client/client-custom.conf
echo "<ca>" >> /etc/openvpn/client/client-custom.conf
cat /etc/openvpn/pki/ca.crt >> /etc/openvpn/client/client-custom.conf
echo "</ca>" >> /etc/openvpn/client/client-custom.conf
echo "" >> /etc/openvpn/client/client-custom.conf

# stunnelClient.conf - Stunnel client config file
echo "# OVPN CLIENT-STUNNEL CONFIG
# ----------------------------
client
pull
dev tun
proto tcp
remote 127.0.0.1 6545
route $ipaddr 255.255.255.255 net_gateway
resolv-retry infinite
persist-key
persist-tun
script-security 3
auth-user-pass
verb 3" > /etc/openvpn/client/client-stunnel.conf

echo "" >> /etc/openvpn/client/client-stunnel.conf
echo "<ca>" >> /etc/openvpn/client/client-stunnel.conf
cat /etc/openvpn/pki/ca.crt >> /etc/openvpn/client/client-stunnel.conf
echo "</ca>" >> /etc/openvpn/client/client-stunnel.conf
echo "" >> /etc/openvpn/client/client-stunnel.conf
echo -e "[ ${GREEN}DONE${PLAIN} ]"

##
# squid package installation & configuration
##
echo -n "Installing squid package..."
apt-get -qq update &>/dev/null
apt-get -y -qq install squid &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create config file for squid..."
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
echo -e "[ ${GREEN}DONE${PLAIN} ]"

##
# stunnel package installation & configuration
##
echo -n "Installing stunnel package..."
apt-get -qq update &>/dev/null
apt-get -y -qq install stunnel &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create file .pem for stunnel..."
openssl req -new -x509 -days 365 -nodes \
-subj '/C=MY/ST=Sabah/L=Tawau/O="Cybertize Devel"/OU="Stunnel Services"/CN=cybertize' \
-out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create config file for stunnel..."
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
echo -e "[ ${GREEN}DONE${PLAIN} ]"

##
# shadowsocks-libev package installation & configuration
##
echo -n "Installing shadowsocks-libev package..."
apt-get -qq update &>/dev/null
apt-get -y -qq install shadowsocks-libev &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create config file for ss-libev..."
echo '{
  "server":["::1", "127.0.0.1"],
  "mode":"tcp_and_udp",
  "server_port":6242,
  "local_port":1080,
  "password":"2021.Cybertize",
  "timeout":60,
  "method":"chacha20-ietf-poly1305"
}' > /etc/shadowsocks-libev/config.json
echo -e "[ ${GREEN}DONE${PLAIN} ]"

##
# simple-obfs package installation & configuration
##
echo -n "Installing simple-obfs package..."
apt-get -qq update &>/dev/null
apt-get -y -qq install simple-obfs &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create config file for simple-obfs..."
echo '{
  "server":"127.0.0.1",
  "server_port":8388,
  "local_port":1080,
  "password":"",
  "timeout":60,
  "method":"chacha20-ietf-poly1305",
  "mode":"tcp_and_udp",
  "fast_open":true,
  "plugin":"obfs-server",
  "plugin_opts":"obfs=tls;failover=127.0.0.1:8443;fast-open"
}' > /etc/simple-server/config.json
echo -e "[ ${GREEN}DONE${PLAIN} ]"

##
# webmin package installation
##
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'

echo -n "Installing webmin package..."
apt-get -qq update &>/dev/null
apt-get -y -qq install webmin &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

##
# fail2ban package installation
##
echo -n "Installing fail2ban package..."
apt-get -qq update &>/dev/null
apt-get -y -qq install fail2ban &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

##
# iptables package file rules
##
echo -n "Create iptables rules file..."
echo '#!/usr/bin/env bash

# Trust the local host
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow incoming
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 5968 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 8695 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 5456 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 6545 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 6753 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 4613 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 3164 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 6242 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 1080 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 7300 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
iptables -A INPUT -p tcp --dport 10000 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT

# Accept established sessions
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# NAT rules
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE' > /etc/iptables.up.rules
echo -e "[ ${GREEN}DONE${PLAIN} ]"

iptables-save > /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules

##
# plugins file
#
echo -n "Copy and Chmod Plugin files..."
wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/menu" &>/dev/null
wget -O /usr/local/bin/create "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/create" &>/dev/null
wget -O /usr/local/bin/active "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/active" &>/dev/null
wget -O /usr/local/bin/password "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/password" &>/dev/null
wget -O /usr/local/bin/login "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/login" &>/dev/null
wget -O /usr/local/bin/lists "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/lists" &>/dev/null
wget -O /usr/local/bin/lock "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/lock" &>/dev/null
wget -O /usr/local/bin/unlock "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/unlock" &>/dev/null
wget -O /usr/local/bin/delete "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/accounts/delete" &>/dev/null
wget -O /usr/local/bin/speedtest "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/server/speedtest" &>/dev/null
wget -O /usr/local/bin/detail "https://raw.githubusercontent.com/cybertize-dev/Debian10/main/plugins/server/detail" &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"

chmod u+x /usr/local/bin/menu

echo ""
echo ""
echo -e "${GREEN}Congratulation, we are done with the setup${PLAIN}"
echo ""
echo ""
