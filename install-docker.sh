#!/bin/bash

base_path="/opt/openvpn-admin"


printf "\n################## Server informations ##################\n"

echo "Server Hostname/IP: $server_address"

if [[ -z ${openvpn_proto} ]]; then
  openvpn_proto="tcp"
fi

echo "OpenVPN protocol (tcp or udp) : ${openvpn_proto}"

if [[ -z ${openvpn_port} ]]; then
  openvpn_port="443"
fi

echo "OpenVPN Port : ${openvpn_port}"


printf "\n################## Certificates informations ##################\n"

echo "Key size (1024, 2048 or 4096) : ${key_size}"

echo "Root certificate expiration (in days) : ${ca_expire}"

echo "Certificate expiration (in days) : ${cert_expire}"

echo "Country Name (2 letter code) : ${cert_country}"

echo "State or Province Name (full name) : ${cert_province}"

echo "Locality Name (eg, city) : ${cert_city}"

echo "Organization Name (eg, company) : ${cert_org}"

echo "Organizational Unit Name (eg, section) : ${cert_ou}"

echo "Email Address : ${cert_email}"

echo "Common Name (eg, your name or your server's hostname) : ${key_cn}"


printf "\n################## Creating the certificates ##################\n"

# Get the rsa keys
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

if [[ ! -z $key_size ]]; then
  export EASYRSA_KEY_SIZE=$key_size
fi
if [[ ! -z $ca_expire ]]; then
  export EASYRSA_CA_EXPIRE=$ca_expire
fi
if [[ ! -z $cert_expire ]]; then
  export EASYRSA_CERT_EXPIRE=$cert_expire
fi
if [[ ! -z $cert_country ]]; then
  export EASYRSA_REQ_COUNTRY=$cert_country
fi
if [[ ! -z $cert_province ]]; then
  export EASYRSA_REQ_PROVINCE=$cert_province
fi
if [[ ! -z $cert_city ]]; then
  export EASYRSA_REQ_CITY=$cert_city
fi
if [[ ! -z $cert_org ]]; then
  export EASYRSA_REQ_ORG=$cert_org
fi
if [[ ! -z $cert_ou ]]; then
  export EASYRSA_REQ_OU=$cert_ou
fi
if [[ ! -z $cert_email ]]; then
  export EASYRSA_REQ_EMAIL=$cert_email
fi
if [[ ! -z $key_cn ]]; then
  export EASYRSA_REQ_CN=$key_cn
fi

# Init PKI dirs and build CA certs
echo "yes" | ./easyrsa init-pki
echo "" | ./easyrsa build-ca nopass
# Generate Diffie-Hellman parameters
./easyrsa gen-dh
# Genrate server keypair
./easyrsa build-server-full server nopass

# Generate shared-secret for TLS Authentication
openvpn --genkey --secret pki/ta.key


printf "\n################## Setup OpenVPN ##################\n"

# Copy certificates and the server configuration in the openvpn directory
cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"
cp "$base_path/installation/server.conf" "/etc/openvpn/"
mkdir "/etc/openvpn/ccd"
sed -i "s/port 443/port $openvpn_port/" "/etc/openvpn/server.conf"

if [ $openvpn_proto = "udp" ]; then
  sed -i "s/proto tcp/proto $openvpn_proto/" "/etc/openvpn/server.conf"
fi

nobody_group=$(id -ng nobody)
sed -i "s/group nogroup/group $nobody_group/" "/etc/openvpn/server.conf"

printf "\n################## Setup firewall ##################\n"

# Make ip forwading and make it persistent
echo 1 > "/proc/sys/net/ipv4/ip_forward"
echo "net.ipv4.ip_forward = 1" >> "/etc/sysctl.conf"

# Get primary NIC device name
primary_nic=`route | grep '^default' | grep -o '[^ ]*$'`

# Iptable rules
iptables -I FORWARD -i tun0 -j ACCEPT
iptables -I FORWARD -o tun0 -j ACCEPT
iptables -I OUTPUT -o tun0 -j ACCEPT

iptables -A FORWARD -i tun0 -o $primary_nic -j ACCEPT
iptables -t nat -A POSTROUTING -o $primary_nic -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $primary_nic -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.2/24 -o $primary_nic -j MASQUERADE


printf "\n################## Setup MySQL database ##################\n"

sleep 10s
echo "CREATE DATABASE \`openvpn-admin\` CHARACTER SET utf8 COLLATE utf8_general_ci" | mysql -h ${mysql_host} -u root --password="${mysql_root_pass}"

printf "\n################## Setup web application ##################\n"

# Copy bash scripts (which will insert row in MySQL)
cp -r "${base_path}/installation/scripts" "/etc/openvpn/"
chmod +x "/etc/openvpn/scripts/"*

# Configure MySQL in openvpn scripts
sed -i "s/HOST=''/HOST='${mysql_host}'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/USER=''/USER='root'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/PASS=''/PASS='${mysql_root_pass}'/" "/etc/openvpn/scripts/config.sh"

printf "\033[1m\n#################################### Finish ####################################\n"

echo -e "# Congratulations, you have successfully setup OpenVPN-Admin! #\r"
echo -e "Please finish install by visiting http://${server_address}:${server_port}/index.php?installation\r"
echo "Please, report any issues here https://github.com/Chocobozzz/OpenVPN-Admin"
printf "\n################################################################################ \033[0m\n"

touch /etc/openvpn/.install-finish
