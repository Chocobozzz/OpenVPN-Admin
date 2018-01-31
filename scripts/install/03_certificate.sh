#!/bin/bash

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
