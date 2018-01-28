#!/bin/bash

print_error() {
    echo "$1"
    exit
}

read_env() {
    source "$1"
#    grep -vE '^#|^$' "$1" | sed -r 's/\ /\\\ /g; s/\=/\t/g' | \
#    while read env val
#        do
#            env - $env="$val"
#    done
}

# Ensure to be root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Read dotEnv file
read_env "$base_path/../.env"

printf "\n################## Server informations ##################\n"

[ ! -z "$VPN_ADDR" ] && echo "VPN_ADDR=$VPN_ADDR"
[ -z "$VPN_ADDR" ]  && read -p "Server Hostname/IP: " VPN_ADDR
[ -z "$VPN_ADDR" ]  && print_error "Server address is required!"

[ ! -z "$VPN_PROTO" ] && echo "VPN_PROTO=$VPN_PROTO"
[ -z "$VPN_PROTO" ] && read -p "OpenVPN protocol (tcp or udp) [tcp]: " VPN_PROTO
[ -z "$VPN_PROTO" ] && VPN_PROTO="tcp"

[ ! -z "$VPN_PORT" ] && echo "VPN_PORT=$VPN_PORT"
[ -z "$VPN_PORT" ]  && read -p "OpenVPN port [443]: " VPN_PORT
[ -z "$VPN_PORT" ]  && VPN_PORT="443"

[ ! -z "$VPN_GROUP" ] && echo "VPN_GROUP=$VPN_GROUP"
[ -z "$VPN_GROUP" ] && read -p "OpenVPN group [nogroup]: " VPN_GROUP
[ -z "$VPN_GROUP" ] && VPN_GROUP="nogroup"

[ ! -z "$VPN_INIF" ] && echo "VPN_INIF=$VPN_INIF"
[ -z "$VPN_INIF" ]  && read -p "OpenVPN input interface [tun0]: " VPN_INIF
[ -z "$VPN_INIF" ]  && VPN_INIF="tun0"

[ ! -z "VPN_OUTIF" ] && echo "VPN_OUTIF=$VPN_OUTIF"
[ -z "$VPN_OUTIF" ] && read -p "OpenVPN output interface [eth0]: " VPN_OUTIF
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


printf "\n################## Creating the certificates ##################\n"

EASYRSA_RELEASES=( $(
  curl -s https://api.github.com/repos/OpenVPN/easy-rsa/releases | \
  grep 'tag_name' | \
  grep -E '3(\.[0-9]+)+' | \
  awk '{ print $2 }' | \
  sed 's/[,|"|v]//g'
) )
EASYRSA_LATEST=${EASYRSA_RELEASES[0]}

# Get the rsa keys
wget -q https://github.com/OpenVPN/easy-rsa/releases/download/v${EASYRSA_LATEST}/EasyRSA-${EASYRSA_LATEST}.tgz -O /tmp/EasyRSA-${EASYRSA_LATEST}.tgz
mkdir -p /etc/openvpn/easy-rsa
tar -xaf /tmp/EasyRSA-${EASYRSA_LATEST}.tgz -C /etc/openvpn/easy-rsa --strip-components=1
rm -r /tmp/EasyRSA-${EASYRSA_LATEST}.tgz
cd /etc/openvpn/easy-rsa

# Init PKI dirs and build CA certs
./easyrsa --batch init-pki
./easyrsa --batch build-ca nopass
# Generate Diffie-Hellman parameters
./easyrsa --batch gen-dh
# Generate server keypair
./easyrsa --batch build-server-full server nopass

# Generate shared-secret for TLS Authentication
openvpn --genkey --secret pki/ta.key


printf "\n################## Setup OpenVPN ##################\n"

# Copy certificates and the server configuration in the openvpn directory
cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"
cp "$base_path/installation/server.conf" "/etc/openvpn/"
mkdir "/etc/openvpn/ccd"
sed -i "s/port 443/port $VPN_PORT/" "/etc/openvpn/server.conf"
sed -i "s/proto tcp/proto $VPN_PROTO/" "/etc/openvpn/server.conf"
sed -i "s/group nogroup/group $VPN_GROUP/" "/etc/openvpn/server.conf"


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
iptables -t nat -A POSTROUTING -s $VPN_NET -o eth0 -j MASQUERADE


printf "\n################## Setup web application ##################\n"

# Copy bash scripts (which will insert row in MySQL)
cp -r "$base_path/installation/scripts" "/etc/openvpn/"
chmod +x "/etc/openvpn/scripts/"*

# Configure MySQL in openvpn scripts
sed -i "s/USER=''/USER='$DB_USER'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/PASS=''/PASS='$DB_PASS'/" "/etc/openvpn/scripts/config.sh"

cp -r "$base_path/installation/client-conf" "$base_path/../public"
# New workspace
cd "$base_path/../public"

# Replace in the client configurations with the ip of the server and openvpn protocol
for file in "./client-conf/gnu-linux/client.conf" "./client-conf/osx-viscosity/client.conf" "./client-conf/windows/client.ovpn"; do
  sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $VPN_ADDR $VPN_PORT/" $file

  if [ $VPN_PROTO = "udp" ]; then
    sed -i "s/proto tcp-client/proto udp/" $file
  fi
done

# Copy ta.key inside the client-conf directory
for directory in "./client-conf/gnu-linux/" "./client-conf/osx-viscosity/" "./client-conf/windows/"; do
  cp "/etc/openvpn/"{ca.crt,ta.key} $directory
done

printf "\033[1m\n#################################### Finish ####################################\n"
