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

echo -n "Server ip: "
read ip_server


# Get root pass (to create the database and the user)
mysql_root_pass=""
status_code=1

while [ $status_code -ne 0 ]; do
  echo -n "Server MySQL root password: "
  read mysql_root_pass
  echo "SHOW DATABASES" | mysql -u root --password="$mysql_root_pass" &> /dev/null
  status_code=$?
done

sql_result=$(echo "SHOW DATABASES" | mysql -u root --password="$mysql_root_pass" | grep -e "^openvpn-admin$")
# Check if the database doesn't already exist
if [ "$sql_result" != "" ]; then
  echo "The database openvpn-admin already exists."
  exit
fi

# Check if the user doesn't already exist
echo -n "Server MySQL openvpn-admin user (will be created): "
read mysql_user

echo "SHOW GRANTS FOR $mysql_user@localhost" | mysql -u root --password="$mysql_root_pass" &> /dev/null
if [ $? -eq 0 ]; then
  echo "The MySQL user already exists."
  exit
fi

echo -n "Server MySQL openvpn-admin user password: "
read mysql_pass


# TODO MySQL port & host ?


printf "\n################## Certificates informations ##################\n"
key_size="0"

while [ "$key_size" != "1024" -a "$key_size" != "2048" -a "$key_size" != "4096" ]; do 
  echo -n "Key size (1024, 2048 or 4096): "
  read key_size
done

echo -n "Root certificate expiration (in days): "
read ca_expire

echo -n "Certificate expiration (in days): "
read key_expire

echo -n "Country: "
read key_country

echo -n "Province: "
read key_province

echo -n "City: "
read key_city

echo -n "Organization: "
read key_org

echo -n "Email: "
read key_email


printf "\n################## Creating the certificates ##################\n"

# Get the rsa keys
mkdir /etc/openvpn/easy-rsa/
wget https://github.com/OpenVPN/easy-rsa/archive/2.2.2.zip
unzip 2.2.2.zip
mv easy-rsa-2.2.2/easy-rsa/2.0/* /etc/openvpn/easy-rsa/
rm -r 2.2.2.zip easy-rsa-2.2.2
cd /etc/openvpn/easy-rsa

source vars

export KEY_SIZE=$key_size
export CA_EXPIRE=$ca_expire
export KEY_EXPIRE=$key_expire
export KEY_COUNTRY=$key_country
export KEY_PROVINCE=$key_province
export KEY_CITY=$key_city
export KEY_ORG=$key_org
export KEY_EMAIL=$key_email

./clean-all
./build-dh
./pkitool --initca
./pkitool --server server
openvpn --genkey --secret keys/ta.key



printf "\n################## Setup OpenVPN ##################\n"

# Copy certificates and the server configuration in the openvpn directory
cp /etc/openvpn/easy-rsa/keys/{ca.crt,ta.key,server.crt,server.key,dh${KEY_SIZE}.pem} "/etc/openvpn/"
cp "$base_path/installation/server.conf" "/etc/openvpn/"


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
chmod +x "/etc/openvpn/scripts/*"

# Create the directory of the web application
mkdir "$openvpn_admin"
cp -r "$base_path/"{index.php,sql,bower.json,.bowerrc,js,include,css,installation/client-conf} "$openvpn_admin"

# New workspace
cd "$openvpn_admin"

# Replace config.php variables
sed -i "s/\$user = '';/\$user = '$mysql_user';/" "./include/config.php"
sed -i "s/\$pass = '';/\$pass = '$mysql_pass';/" "./include/config.php"

# Replace in the client configurations with the ip of the server
sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $ip_server 443/" "./client-conf/gnu-linux/client.conf"
sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $ip_server 443/" "./client-conf/windows/client.conf"

# Copy ta.key inside the client-conf directory
cp "/etc/openvpn/ta.key" "./client-conf/gnu-linux/"
cp "/etc/openvpn/ta.key" "./client-conf/windows/"

# Install third parties
bower --allow-root install
chown -R "$user:$group" "$openvpn_admin"


printf "\n################## Finish ##################\n"

echo "Congratulation, you have successfuly setup openvpn-admin. Please, finish the installation by configuring your web server (Apache, NGinx...) and install the web application by visiting http://your-installation/index.php?installation"
echo "Then, you will be able to run OpenVPN with systemctl start openvpn@server"
echo "Please, report any issues here https://github.com/Chocobozzz/OpenVPN-Admin"
