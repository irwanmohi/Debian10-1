#!/usr/bin/env bash

ipaddr=$( ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1 )
. $basepath/_sources/includes/colors

until [[ $YESNO =~ (y|n) ]]; do
  read -rp "Do you want to continue? [y/n]: " YESNO
done
if [[ ! $YESNO =~ ^[Yy]$ ]] ; then
  echo "Goodbye..." && exit
fi

echo -n "Installing openvpn package "
apt-get -qq update &>/dev/null
apt-get -y -qq install openvpn &>/dev/null
rm -r server
echo -e "[ ${GREEN}DONE${PLAIN} ]"

echo -n "Create openvpn cert and key "
echo "Please wait, this will take a while..."

cd /usr/share/easy-rsa
{
  ./easyrsa --batch init-pki
  ./easyrsa --batch build-ca nopass
  ./easyrsa --batch gen-dh
  openvpn --genkey --secret /usr/share/easy-rsa/pki/ta.key
  ./easyrsa --batch build-server-full server nopass
} &>/dev/null

cp -R /usr/share/easy-rsa/pki /etc/openvpn/
echo " Done"

# /etc/openvpn/servcustom.conf
{
  echo "# OVPN SERVER-CUSTOM CONFIG
# ----------------------------
port 5456
proto tcp
dev tun

ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/pki/ta.key 0

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
username-as-common-name" > /etc/openvpn/servcustom.conf
} &>/dev/null

# /etc/openvpn/servstunnel.conf
{
  echo "# OVPN SERVER-STUNNEL CONFIG
# ----------------------------
port 6545
proto tcp
dev tun

ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/pki/ta.key 0

verify-client-cert none
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push \"redirect-gateway def1 bypass-dhcp\"
push \"dhcp-option DNS 1.1.1.1\"
push \"dhcp-option DNS 1.0.0.1\"
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
username-as-common-name" > /etc/openvpn/servstunnel.conf
} &>/dev/null

# /etc/openvpn/servobfs.conf
{
  echo "# OVPN SERVER-OBFS CONFIG
# ----------------------------
port 6753
proto tcp
dev tun

ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/pki/ta.key 0

verify-client-cert none
server 10.10.0.0 255.255.255.0
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
username-as-common-name" > /etc/openvpn/servobfs.conf
} &>/dev/null


# customClient.conf - Custom client config file
{
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
;http-proxy [proxy] [port]
;http-proxy-option CUSTOM-HEADER Protocol HTTP/1.1
;http-proxy-option CUSTOM-HEADER Host HOSTNAME" > /etc/openvpn/client/client-custom.conf

echo "" >> /etc/openvpn/client/client-custom.conf
echo "<ca>" >> /etc/openvpn/client/client-custom.conf
cat /etc/openvpn/pki/ca.crt >> /etc/openvpn/client/client-custom.conf
echo "</ca>" >> /etc/openvpn/client/client-custom.conf
echo "" >> /etc/openvpn/client/client-custom.conf
echo "<tls-auth>" >> /etc/openvpn/client/client-custom.conf
cat /etc/openvpn/pki/ta.key >> /etc/openvpn/client/client-custom.conf
echo "</tls-auth>" >> /etc/openvpn/client/client-custom.conf
} &>/dev/null

# stunnelClient.conf - Stunnel client config file
{
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
echo "<tls-auth>" >> /etc/openvpn/client/client-stunnel.conf
cat /etc/openvpn/pki/ta.key >> /etc/openvpn/client/client-stunnel.conf
echo "</tls-auth>" >> /etc/openvpn/client/client-stunnel.conf
} &>/dev/null

# obfs4Client.conf - obfsproxy client config file
{
  echo "# OVPN CLIENT-OBFS4 CONFIG
# ----------------------------
client
pull
dev tun
proto tcp
remote $ipaddr 6753
socks-proxy 127.0.0.1 9090
route $ipaddr 255.255.255.255 net_gateway
resolv-retry infinite
persist-key
persist-tun
script-security 3
auth-user-pass
verb 3" > /etc/openvpn/client/client-obfs.conf

echo "" >> /etc/openvpn/client/client-obfs.conf
echo "<ca>" >> /etc/openvpn/client/client-obfs.conf
cat /etc/openvpn/pki/ca.crt >> /etc/openvpn/client/client-obfs.conf
echo "</ca>" >> /etc/openvpn/client/client-obfs.conf
echo "" >> /etc/openvpn/client/client-obfs.conf
echo "<tls-auth>" >> /etc/openvpn/client/client-obfs.conf
cat /etc/openvpn/pki/ta.key >> /etc/openvpn/client/client-obfs.conf
echo "</tls-auth>" >> /etc/openvpn/client/client-obfs.conf
} &>/dev/null

echo ""
echo -e "${GREEN}Congratulation, we are done with openvpn setup${PLAIN}"
echo ""
echo "=============================================="
echo -e "${CYAN}[ OPENVPN DETAILS ]${PLAIN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Service:${PLAIN} ${GREEN}Started & Enabled${PLAIN}"
echo -e "${YELLOW}Hostname:${PLAIN} ${GREEN}cybertize.tk${PLAIN}"
echo -e "${YELLOW}Ipaddress:${PLAIN} ${GREEN}$ipaddr${PLAIN}"
echo -e "${YELLOW}Custom Client:${PLAIN} ${GREEN}5456${PLAIN}"
echo -e "${YELLOW}Stunnel Client:${PLAIN} ${GREEN}6545${PLAIN}"
echo -e "${YELLOW}Obfs Client:${PLAIN} ${GREEN}6753${PLAIN}"
echo "----------------------------------------------"
echo -e "${YELLOW}Start OpenVPN services:${PLAIN}"
echo -e "${GREEN}systemctl start openvpn@servcustom${PLAIN}"
echo -e "${GREEN}systemctl start openvpn@servstunnel${PLAIN}"
echo -e "${GREEN}systemctl start openvpn@servobfs${PLAIN}"
echo "=============================================="
