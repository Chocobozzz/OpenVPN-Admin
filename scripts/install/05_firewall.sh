#!/bin/bash

printf "\n################## Setup firewall ##################\n"

# Make ip forwading and make it persistent
echo 1 > "/proc/sys/net/ipv4/ip_forward"
echo "net.ipv4.ip_forward = 1" >> "/etc/sysctl.conf"

# Iptable rules
iptables -I FORWARD -i $VPN_INIF -j ACCEPT
iptables -I FORWARD -o $VPN_INIF -j ACCEPT
iptables -I OUTPUT -o $VPN_INIF -j ACCEPT

iptables -A FORWARD -i $VPN_INIF -o $VPN_OUTIF -j ACCEPT
iptables -t nat -A POSTROUTING -o $VPN_OUTIF -j MASQUERADE
iptables -t nat -A POSTROUTING -s $VPN_NET -o $VPN_OUTIF -j MASQUERADE
