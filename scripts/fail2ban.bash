#!/usr/bin/env bash

ipaddr=$( ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1 )
. root/Debian10-main/_sources/includes/colors

until [[ $YESNO =~ (y|n) ]]; do
  read -rp "Do you want to continue? [y/n]: " YESNO
done
if [[ ! $YESNO =~ ^[Yy]$ ]] ; then
  echo "Goodbye..." && exit
fi

echo -n "Installing Dropbear package"
apt-get -qq update &>/dev/null
apt-get -y -qq install fail2ban &>/dev/null
echo -e "[ ${GREEN}DONE${PLAIN} ]"
