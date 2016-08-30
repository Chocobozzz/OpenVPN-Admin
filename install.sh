#!/bin/bash

print_help () {
  echo -e "./install.sh www_basedir user group"
  echo -e "\tbase_dir: The place where the web application will be put in"
  echo -e "\tuser:     User of the web application"
  echo -e "\tgroup:    Group of the web application"
}

# Ensure to be root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Ensure there are enought arguments
if [ "$#" -ne 3 ]; then
  print_help
  exit
fi

# Ensure there are the prerequisites
for i in openvpn mysql php bower node unzip wget sed; do
  which $i > /dev/null
  if [ "$?" -ne 0 ]; then
    echo "Miss $i"
    exit
  fi
done

www=$1
user=$2
group=$3
openvpn_admin="$www/openvpn-admin"

# Check the validity of the arguments
if [ ! -d "$www" ] ||  ! grep -q "$user" "/etc/passwd" || ! grep -q "$group" "/etc/group" ; then
  print_help
  exit
fi

base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


printf "\n################## Server informations ##################\n"

read -p "Server ip: " ip_server

read -p "Port [default: 443]: " server_port

if [[ "$server_port" == "443" || "$server_port" == "" ]]; then
  server_port="443"
else
  server_port=$server_port
fi

# Get root pass (to create the database and the user)
mysql_root_pass=""
status_code=1

while [ $status_code -ne 0 ]; do
  read -p "Server MySQL root password: " -s mysql_root_pass; echo
  if [ "$mysql_root_pass" != "" ]; then
      echo "SHOW DATABASES" | mysql -u root --password="$mysql_root_pass" &> /dev/null
      status_code=$?
  else
    echo "MySQL root password is empty!"
    exit
  fi
done

sql_result=$(echo "SHOW DATABASES" | mysql -u root --password="$mysql_root_pass" | grep -e "^openvpn-admin$")
# Check if the database doesn't already exist
if [ "$sql_result" != "" ]; then
  echo "The database openvpn-admin already exists."
  exit
fi


# Check if the user doesn't already exist
read -p "Server MySQL openvpn-admin user (will be created): " mysql_user

echo "SHOW GRANTS FOR $mysql_user@localhost" | mysql -u root --password="$mysql_root_pass" &> /dev/null
if [ $? -eq 0 ]; then
  echo "The MySQL user already exists."
  exit
fi

read -p "Server MySQL openvpn-admin user password: " -s mysql_pass; echo


# TODO MySQL port & host ?


printf "\n################## Certificates informations ##################\n"

while [ "$key_size" != "1024" -a "$key_size" != "2048" -a "$key_size" != "4096" ]; do
  read -p "Key size (1024, 2048 or 4096): " key_size
done

read -p "Root certificate expiration (in days): " ca_expire

read -p "Certificate expiration (in days): " key_expire

read -p "Country Name (2 letter code): " key_country

read -p "State or Province Name (full name): " key_province

read -p "Locality Name (eg, city): " key_city

read -p "Organization Name (eg, company): " key_org

read -p "Email Address: " key_email

read -p "Common Name (eg, your name or your server's hostname): " key_cn

read -p "Name (eg, your name or your server's hostname): " key_name

read -p "Organizational Unit Name (eg, section): " key_ou


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
wget -q --show-progress https://github.com/OpenVPN/easy-rsa/releases/download/${EASYRSA_LATEST}/EasyRSA-${EASYRSA_LATEST}.tgz
tar -xaf EasyRSA-${EASYRSA_LATEST}.tgz
mv EasyRSA-${EASYRSA_LATEST} /etc/openvpn/easy-rsa
rm -r EasyRSA-${EASYRSA_LATEST}.tgz
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
./easyrsa init-pki
./easyrsa build-ca nopass
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
sed -i "s/dh dh1024\.pem/dh dh${KEY_SIZE}.pem/" "/etc/openvpn/server.conf"
sed -i "s/port 443/port $server_port/" "/etc/openvpn/server.conf"


printf "\n################## Setup firewall ##################\n"

# Make ip forwading and make it persistent
echo 1 > "/proc/sys/net/ipv4/ip_forward"
echo "net.ipv4.ip_forward = 1" >> "/etc/sysctl.conf"

# Iptable rules
iptables -I FORWARD -i tun0 -j ACCEPT
iptables -I FORWARD -o tun0 -j ACCEPT
iptables -I OUTPUT -o tun0 -j ACCEPT

iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.2/24 -o eth0 -j MASQUERADE


printf "\n################## Setup MySQL database ##################\n"

echo "CREATE DATABASE \`openvpn-admin\`" | mysql -u root --password="$mysql_root_pass"
echo "CREATE USER $mysql_user@localhost IDENTIFIED BY '$mysql_pass'" | mysql -u root --password="$mysql_root_pass"
echo "GRANT ALL PRIVILEGES ON \`openvpn-admin\`.*  TO $mysql_user@localhost" | mysql -u root --password="$mysql_root_pass"
echo "FLUSH PRIVILEGES" | mysql -u root --password="$mysql_root_pass"


printf "\n################## Setup web application ##################\n"

# Copy bash scripts (which will insert row in MySQL)
cp -r "$base_path/installation/scripts" "/etc/openvpn/"
chmod +x "/etc/openvpn/scripts/"*

# Configure MySQL in openvpn scripts
sed -i "s/USER=''/USER='$mysql_user'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/PASS=''/PASS='$mysql_pass'/" "/etc/openvpn/scripts/config.sh"

# Create the directory of the web application
mkdir "$openvpn_admin"
cp -r "$base_path/"{index.php,sql,bower.json,.bowerrc,js,include,css,installation/client-conf} "$openvpn_admin"

# New workspace
cd "$openvpn_admin"

# Replace config.php variables
sed -i "s/\$user = '';/\$user = '$mysql_user';/" "./include/config.php"
sed -i "s/\$pass = '';/\$pass = '$mysql_pass';/" "./include/config.php"

# Replace in the client configurations with the ip of the server
sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $ip_server $server_port/" "./client-conf/gnu-linux/client.conf"
sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $ip_server $server_port/" "./client-conf/windows/client.ovpn"

# Copy ta.key inside the client-conf directory
cp "/etc/openvpn/"{ca.crt,ta.key} "./client-conf/gnu-linux/"
cp "/etc/openvpn/"{ca.crt,ta.key} "./client-conf/windows/"

# Install third parties
bower --allow-root install
chown -R "$user:$group" "$openvpn_admin"


printf "\n################## Finish ##################\n"

echo "Congratulation, you have successfuly setup openvpn-admin. Please, finish the installation by configuring your web server (Apache, NGinx...) and install the web application by visiting http://your-installation/index.php?installation"
echo "Then, you will be able to run OpenVPN with systemctl start openvpn@server"
echo "Please, report any issues here https://github.com/Chocobozzz/OpenVPN-Admin"
