#!/bin/bash

printf "\n################## Setup OpenVPN ##################\n"

# Copy certificates and the server configuration in the openvpn directory
cp "$VPN_CONF/easy-rsa/pki/"{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "$VPN_CONF/"

# Certs must be readable via web interface
chmod +r $VPN_CONF/{ca.crt,ta.key}

# Configuration directory of the clients
mkdir -p "$VPN_CONF/ccd"

# Generate server config
php -f "$base_path/server-conf.php" > "$VPN_CONF/server.conf"
