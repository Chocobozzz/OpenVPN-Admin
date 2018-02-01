#!/bin/bash

printf "\n################## Setup OpenVPN ##################\n"

# Copy certificates and the server configuration in the openvpn directory
cp "$VPN_CONF/easy-rsa/pki/"{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "$VPN_CONF/"
chmod +r $VPN_CONF/{ca.crt,ta.key}
cp "$base_path/../configs/server.conf" "$VPN_CONF/"
mkdir -p "$VPN_CONF/ccd"

sed "
s/VPN_SERVER/$VPN_SERVER/;
s/VPN_PORT/$VPN_PORT/
s/VPN_INIF/$VPN_INIF/
s/VPN_PROTO/$VPN_PROTO/
s/VPN_GROUP/$VPN_GROUP/
s/VPN_USER/$VPN_USER/
s|SCRIPTS_LOGIN|$SCRIPTS_LOGIN|
s|SCRIPTS_CONNECT|$SCRIPTS_CONNECT|
s|SCRIPTS_DISCONNECT|$SCRIPTS_DISCONNECT|
" -i "$VPN_CONF/server.conf"
