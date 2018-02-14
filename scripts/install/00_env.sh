#!/bin/bash

printf "\n################## Server informations ##################\n"

[ ! -z "$VPN_LISTEN" ] && echo "VPN_LISTEN=$VPN_LISTEN"
[ -z "$VPN_LISTEN" ]  && read -p "Server local Hostname/IP: " VPN_LISTEN
[ -z "$VPN_LISTEN" ]  && print_error "Server local address is required!"

[ ! -z "$VPN_LISTEN_PORT" ] && echo "VPN_LISTEN_PORT=$VPN_LISTEN_PORT"
[ -z "$VPN_LISTEN_PORT" ]  && read -p "OpenVPN listen port [1194]: " VPN_LISTEN_PORT
[ -z "$VPN_LISTEN_PORT" ]  && VPN_LISTEN_PORT="1194"

[ ! -z "$VPN_REMOTE" ] && echo "VPN_REMOTE=$VPN_REMOTE"
[ -z "$VPN_REMOTE" ]  && read -p "Server remote Hostname/IP: " VPN_REMOTE
[ -z "$VPN_REMOTE" ]  && print_error "Server remote address is required!"

[ ! -z "$VPN_REMOTE_PORT" ] && echo "VPN_REMOTE_PORT=$VPN_REMOTE_PORT"
[ -z "$VPN_REMOTE_PORT" ]  && read -p "OpenVPN remote port [443]: " VPN_REMOTE_PORT
[ -z "$VPN_REMOTE_PORT" ]  && VPN_REMOTE_PORT="443"

[ ! -z "$VPN_PROTO" ] && echo "VPN_PROTO=$VPN_PROTO"
[ -z "$VPN_PROTO" ] && read -p "OpenVPN protocol (tcp or udp) [tcp]: " VPN_PROTO
[ -z "$VPN_PROTO" ] && VPN_PROTO="tcp"

[ ! -z "$VPN_USER" ] && echo "VPN_USER=$VPN_USER"
[ -z "$VPN_USER" ] && read -p "OpenVPN user [nobody]: " VPN_USER
[ -z "$VPN_USER" ] && VPN_USER="nobody"

[ ! -z "$VPN_GROUP" ] && echo "VPN_GROUP=$VPN_GROUP"
[ -z "$VPN_GROUP" ] && read -p "OpenVPN group [nogroup]: " VPN_GROUP
[ -z "$VPN_GROUP" ] && VPN_GROUP="nogroup"

[ ! -z "$VPN_DEV" ] && echo "VPN_DEV=$VPN_DEV"
[ -z "$VPN_DEV" ]  && read -p "OpenVPN tunnel interface [tun0]: " VPN_DEV
[ -z "$VPN_DEV" ]  && VPN_DEV="tun0"

[ ! -z "$VPN_IF" ] && echo "VPN_IF=$VPN_IF"
[ -z "$VPN_IF" ] && read -p "OpenVPN physical interface [eth0]: " VPN_IF
[ -z "$VPN_IF" ] && VPN_IF="eth0"

[ ! -z "$VPN_NET" ] && echo "VPN_NET=$VPN_NET"
[ -z "$VPN_NET" ]   && read -p "OpenVPN clients subnet [10.8.0.0/24]: " VPN_NET
[ -z "$VPN_NET" ]   && VPN_NET="10.8.0.0/24"

printf "\n################## Application informations ##################\n"

[ ! -z "$APP_PATH" ] && echo "APP_PATH=$APP_PATH"
[ -z "$APP_PATH" ]   && read -p "Web application root folder [/var/www/html]: " APP_PATH
[ -z "$APP_PATH" ]   && APP_PATH="/var/www/html"

[ ! -z "$SCRIPTS_PATH" ] && echo "SCRIPTS_PATH=$SCRIPTS_PATH"
[ -z "$SCRIPTS_PATH" ]   && read -p "Folder with scripts for OpenVPN [$APP_PATH/scripts/auth-bash]: " SCRIPTS_PATH
[ -z "$SCRIPTS_PATH" ]   && SCRIPTS_PATH="$APP_PATH/scripts/auth-bash"

SCRIPTS_LOGIN="$SCRIPTS_PATH/login.sh"
[ ! -z "$SCRIPTS_LOGIN" ] && echo "SCRIPTS_LOGIN=$SCRIPTS_LOGIN"

SCRIPTS_CONNECT="$SCRIPTS_PATH/connect.sh"
[ ! -z "$SCRIPTS_CONNECT" ] && echo "SCRIPTS_CONNECT=$SCRIPTS_CONNECT"

SCRIPTS_DISCONNECT="$SCRIPTS_PATH/disconnect.sh"
[ ! -z "$SCRIPTS_DISCONNECT" ] && echo "SCRIPTS_DISCONNECT=$SCRIPTS_DISCONNECT"

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
