#!/bin/bash

printf "\n################## Setup OpenVPN ##################\n"

# Copy certificates and the server configuration in the openvpn directory
cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"
chmod +r /etc/openvpn/{ca.crt,ta.key}
cp "$base_path/../configs/server.conf" "/etc/openvpn/"
mkdir -p "/etc/openvpn/ccd"
sed -i "
s/VPN_SERVER/$VPN_SERVER/;
s/VPN_PORT/$VPN_PORT/;
s/VPN_INIF/$VPN_INIF/;
s/VPN_PROTO/$VPN_PROTO/;
s/VPN_GROUP/$VPN_GROUP/" "/etc/openvpn/server.conf"
