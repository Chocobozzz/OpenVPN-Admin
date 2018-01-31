#!/bin/bash

printf "\n################## Server informations ##################\n"

[ ! -z "$VPN_LOCAL" ] && echo "VPN_LOCAL=$VPN_LOCAL"
[ -z "$VPN_LOCAL" ]  && read -p "Server local Hostname/IP: " VPN_LOCAL
[ -z "$VPN_LOCAL" ]  && print_error "Server local address is required!"

[ ! -z "$VPN_REMOTE" ] && echo "VPN_LOCAL=$VPN_REMOTE"
[ -z "$VPN_REMOTE" ]  && read -p "Server remote Hostname/IP: " VPN_REMOTE
[ -z "$VPN_REMOTE" ]  && print_error "Server remote address is required!"

[ ! -z "$VPN_PROTO" ] && echo "VPN_PROTO=$VPN_PROTO"
[ -z "$VPN_PROTO" ] && read -p "OpenVPN protocol (tcp or udp) [tcp]: " VPN_PROTO
[ -z "$VPN_PROTO" ] && VPN_PROTO="tcp"

[ ! -z "$VPN_PORT" ] && echo "VPN_PORT=$VPN_PORT"
[ -z "$VPN_PORT" ]  && read -p "OpenVPN port [443]: " VPN_PORT
[ -z "$VPN_PORT" ]  && VPN_PORT="443"

[ ! -z "$VPN_USER" ] && echo "VPN_USER=$VPN_USER"
[ -z "$VPN_USER" ] && read -p "OpenVPN user [nobody]: " VPN_USER
[ -z "$VPN_USER" ] && VPN_USER="nobody"

[ ! -z "$VPN_GROUP" ] && echo "VPN_GROUP=$VPN_GROUP"
[ -z "$VPN_GROUP" ] && read -p "OpenVPN group [nogroup]: " VPN_GROUP
[ -z "$VPN_GROUP" ] && VPN_GROUP="nogroup"

[ ! -z "$VPN_INIF" ] && echo "VPN_INIF=$VPN_INIF"
[ -z "$VPN_INIF" ]  && read -p "OpenVPN tunnel interface [tun0]: " VPN_INIF
[ -z "$VPN_INIF" ]  && VPN_INIF="tun0"

[ ! -z "$VPN_OUTIF" ] && echo "VPN_OUTIF=$VPN_OUTIF"
[ -z "$VPN_OUTIF" ] && read -p "OpenVPN physical interface [eth0]: " VPN_OUTIF
[ -z "$VPN_OUTIF" ] && VPN_OUTIF="eth0"

[ ! -z "$VPN_NET" ] && echo "VPN_NET=$VPN_NET"
[ -z "$VPN_NET" ]   && read -p "OpenVPN clients subnet [10.8.0.0/24]: " VPN_NET
[ -z "$VPN_NET" ]   && VPN_NET="10.8.0.0/24"


printf "\n################## Certificates informations ##################\n"

[ -z "$EASYRSA_KEY_SIZE" ]      && read -p "Key size (1024, 2048 or 4096) [2048]: " EASYRSA_KEY_SIZE
[ -z "$EASYRSA_CA_EXPIRE" ]     && read -p "Root certificate expiration (in days) [3650]: " EASYRSA_CA_EXPIRE
[ -z "$EASYRSA_CERT_EXPIRE" ]   && read -p "Certificate expiration (in days) [3650]: " EASYRSA_CERT_EXPIRE
[ -z "$EASYRSA_REQ_COUNTRY" ]   && read -p "Country Name (2 letter code) [US]: " EASYRSA_REQ_COUNTRY
[ -z "$EASYRSA_REQ_PROVINCE" ]  && read -p "State or Province Name (full name) [California]: " EASYRSA_REQ_PROVINCE
[ -z "$EASYRSA_REQ_CITY" ]      && read -p "Locality Name (eg, city) [San Francisco]: " EASYRSA_REQ_CITY
[ -z "$EASYRSA_REQ_ORG" ]       && read -p "Organization Name (eg, company) [Copyleft Certificate Co]: " EASYRSA_REQ_ORG
[ -z "$EASYRSA_REQ_OU" ]        && read -p "Organizational Unit Name (eg, section) [My Organizational Unit]: " EASYRSA_REQ_OU
[ -z "$EASYRSA_REQ_EMAIL" ]     && read -p "Email Address [me@example.net]: " EASYRSA_REQ_EMAIL
[ -z "$EASYRSA_REQ_CN" ]        && read -p "Common Name (eg, your name or your server's hostname) [ChangeMe]: " EASYRSA_REQ_CN
