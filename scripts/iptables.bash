#!/usr/bin/env bash

# Remove any existing rules from all chains
iptables -F
iptables -F -t nat
iptables -F -t mangle

# Remove any pre-existing user-defined rules
iptables -X
iptables -X -t nat
iptables -X -t mangle

# Zero the counters
iptables -Z

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
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE