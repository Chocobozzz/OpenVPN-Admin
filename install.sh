#!/bin/bash

# On-Screen Colors
NC='\033[0m'            # No Color
Red='\033[1;31m'        # Light Red
Yellow='\033[0;33m'     # Yellow
Green='\033[0;32m'      # Green

### Variables
OS=$(cat /etc/os-release | grep PRETTY_NAME | sed 's/"//g' | cut -f2 -d= | cut -f1 -d " ") # Don't change this unless you know what you're doing
OS_Version_Major=$(cat /etc/os-release | grep PRETTY_NAME | sed 's/"//g' | cut -f2 -d= | cut -f2 -d " " | cut -f1 -d ".")
OS_Version_Minor=$(cat /etc/os-release | grep PRETTY_NAME | sed 's/"//g' | cut -f2 -d= | cut -f2 -d " " | cut -f2 -d ".")
if [ "$OS" == "Ubuntu" ] || [ "$OS" == "Raspbian" ]; 
then
  :
else
  echo -e "${Red}Oops! Only Ubuntu and Raspbian OS are supported.${NC}"
  exit
fi

timezone="America/Los_Angeles" # this is PHP timezone
gmt_offset="-8:00" # this is MySQL timezone
www=$1
user=$2
group=$3

# OpenVPN
openvpn_admin="$www/openvpn-admin"
base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ip_server=$(hostname -I | cut -f1 -d\ ) # added cut to remove openvpn tunnel IP from the string
public_ip=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}') # don't change this
openvpn_proto="udp" # UDP is a faster protocol than TCP
server_port="1194"  # OpenVPN default port is 1194

# MySQL Variables 
mysql_root_pass=$(openssl rand -base64 12 | sed 's/[^a-zA-Z0-9]//g') # Random ceated secure string without special chatacters
mysql_user=$(openssl rand -base64 12 | sed 's/[^a-zA-Z0-9]//g') # Random ceated secure string without special chatacters
mysql_pass=$(openssl rand -base64 12 | sed 's/[^a-zA-Z0-9]//g') # Random ceated secure string without special chatacters

# Certificates Variables
key_size="2048" # anything less than 2048 may get rejected by some OSes. bigger sizes will take forever to generate!
ca_expire="36500" # 100 Years
cert_expire="36500"
cert_country="US"
cert_province="California"
cert_city="Mission Viejo"
cert_org="PACMIT"
cert_ou="IT"
cert_email="example@test.net"
key_cn=$public_ip # will be changed when asking for public IP/Hostname user input

# show on-screen help
print_help () {
  echo -e "sudo ./install.sh www_basedir user group"
  echo -e "\tbase_dir: The place where the web application will be put in (e.g. /var/www)"
  echo -e "\tuser:     User of the web application (e.g. www-data)"
  echo -e "\tgroup:    Group of the web application (e.g. www-data)"
}

# Ensure to be root
if [ "$EUID" -ne 0 ]; then
  echo -e "${Red}Please use sudo to run the script. e.g:${NC}"
  echo -e "${Green}sudo ./install.sh /var/www www-data www-data${NC}"
  exit
fi

# Ensure there are enought arguments
if [ "$#" -ne 3 ]; then
  print_help
  exit
fi

echo -e "${Green}\nAutomated Installation Started\n"
sleep 2

# hostname / IP settings 
echo -e "${Red}$public_ip ${NC}detected as your Public IP and will be used automatically if you don't choose anything else."
echo -e "Timeout: 2 Minutes"
echo -e "Need to use another public IP or Hostname?"
read -t 120 -p "Type it here or hit enter to continue with detected IP: " public_hostname </dev/tty

if [ -z "$public_hostname" ]
then
  public_ip=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')
  echo -e "\n${NC}Selected IP: ${Red}$public_ip ${NC}"
else
  public_ip=$public_hostname
  key_cn=$public_ip
  echo -e "\n${NC}Selected IP/Hostname: ${Red}$public_ip ${NC}"
fi
echo -e "\n\n\nSelect the VPN connection name for showing up on your client OpenVPN application."
echo -e "This will help the user identify which VPN he is connecting to if he has multiple connection configuration."
echo -e "Default file names will be used if you don't choose any. You may use your company or office Name. (e.g. LA Office)"
echo -e "Timeout: 2 Minutes"
read -t 120 -p "Type it here or hit enter to use default naming (without .ovpn): " company_name </dev/tty

if [ -z "$company_name" ]
then
  echo -e "\nDefault file name VPN.ovpn selected."
else
  echo -e "\nSelected file name: ${Red}$company_name.ovpn${NC}"
fi

echo -e "${Yellow}\nNow sit back and wait for the script to finish the install\n${NC}"
sleep 2

# Detecting OS Distribution
echo -e "${NC}Detected OS: ${Red}$OS $OS_Version_Major.$OS_Version_Minor\n"
sleep 2

# Installing prerequisites
echo -e "${Green}Installing Prerequisites ${Red}(This could take long time)${NC}"

case $OS in
	Ubuntu)
            if [["$OS_Version_Major" > "20"]]
            then
            echo "here"
    		  export DEBIAN_FRONTEND=noninteractive
            echo "export"

              apt install -y software-properties-common ca-certificates lsb-release apt-transport-https
            echo "apt Install"
              LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
              echo "repository add"
              apt-get update && sudo apt-get upgrade -y
    		  apt-get install -y openvpn apache2 mysql-server php7.4 php7.4-mysql php7.4-zip unzip git wget sed curl nodejs npm mc net-tools
              a2dismod php8.1
              a2enmod php7.4
              systemctl restart apache2
            else
              apt update && sudo apt upgrade -y
              apt install -y openvpn apache2 mysql-server php php-mysql php-zip unzip git wget sed curl nodejs npm mc net-tools
            fi
		;;
	Raspbian)
		apt install -y openvpn apache2 mariadb-server php php-mysql php-zip unzip git wget sed curl nodejs npm mc
		;;
	*)
		echo -e "${Red}Can't detect OS distribution! you need to install prerequisites manully${NC}"
    exit
esac
npm install -g bower

# Ensure the prerequisites are installed
for i in openvpn apache2 mysql php unzip git wget sed curl nodejs npm; do
  which $i > /dev/null
  if [ "$?" -ne 0 ]; then
    echo -e "${Red}$i is missing. Please install $i manually.${NC}"
    exit
  fi
done

# setting up MySQL and secure it
echo -e "${Green}Setting MySQL Configuration${NC}"
mysql -u root <<-EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$mysql_root_pass';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

# Check the validity of the arguments
if [ ! -d "$www" ] ||  ! grep -q "$user" "/etc/passwd" || ! grep -q "$group" "/etc/group" ; then
  print_help
  exit
fi

# Get root pass (to create the database and the user)
status_code=1

while [ $status_code -ne 0 ]; do
  echo "SHOW DATABASES" | mysql -u root --password="$mysql_root_pass" &> /dev/null
  status_code=$?
done

sql_result=$(echo "SHOW DATABASES" | mysql -u root --password="$mysql_root_pass" | grep -e "^openvpn-admin$")
# Check if the database doesn't already exist
if [ "$sql_result" != "" ]; then
  echo "The openvpn-admin database already exists."
  exit
fi

echo -e "${Green}Generating OpenVPN-Admin SQL DB user credentials\n"

# Check if the user doesn't already exist
echo "SHOW GRANTS FOR $mysql_user@localhost" | mysql -u root --password="$mysql_root_pass" &> /dev/null
if [ $? -eq 0 ]; then
  echo "The MySQL user already exists."
  exit
fi

echo -e "${Green}Creating the Certificates${Yellow}"

# Get the rsa keys
EASYRSA_VERSION=$(curl -s https://api.github.com/repos/OpenVPN/easy-rsa/releases/latest | grep "tag_name" | cut -f2 -d "v" | sed 's/[",]//g')
EASYRSA_LOCATION=$(curl -s https://api.github.com/repos/OpenVPN/easy-rsa/releases/latest \
| grep "tag_name" \
| awk '{print "https://github.com/OpenVPN/easy-rsa/releases/download/" substr($2, 2, length($2)-3) "/EasyRSA-" substr($2, 3, length($2)-4) ".tgz"}') \
; curl -L -o easyrsa.tgz $EASYRSA_LOCATION

tar -xaf "easyrsa.tgz"
mv "EasyRSA-$EASYRSA_VERSION" /etc/openvpn/easy-rsa
rm "easyrsa.tgz"

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

export EASYRSA_BATCH=1

# Init PKI dirs and build CA certs
./easyrsa init-pki
./easyrsa build-ca nopass
# Generate Diffie-Hellman parameters
./easyrsa gen-dh
# Genrate server keypair
./easyrsa build-server-full server nopass

# Generate shared-secret for TLS Authentication
openvpn --genkey secret pki/ta.key

echo -e "${Green}Setup OpenVPN${NC}"

# Copy certificates and the server configuration in the openvpn directory
cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"
cp "$base_path/installation/server.conf" "/etc/openvpn/"
mkdir "/etc/openvpn/ccd"
sed -i "s/port 1194/port $server_port/" "/etc/openvpn/server.conf"

if [ $openvpn_proto = "udp" ]; then
  sed -i "s/proto tcp/proto $openvpn_proto/" "/etc/openvpn/server.conf"
fi

nobody_group=$(id -ng nobody)
sed -i "s/group nogroup/group $nobody_group/" "/etc/openvpn/server.conf"

echo -e "${Green}Setup Firewall${NC}"

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

# Make ip forwading and make it persistent
case $OS in
  Ubuntu)
    sysctl -w net.ipv4.ip_forward=1
    sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" "/etc/sysctl.conf"
    iptables-save -f ./rules.v4
    if [[ ! -d "/etc/iptables" ]]
    then
      mkdir /etc/iptables
    fi
    mv ./rules.v4 /etc/iptables
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    apt-get install -y iptables-persistent
    ;;
  Raspbian)
    echo 1 > "/proc/sys/net/ipv4/ip_forward"
    ;;
esac

echo -e "${Green}Setup MySQL Database${NC}"

echo "CREATE DATABASE \`openvpn-admin\`" | mysql -u root --password="$mysql_root_pass"
echo "CREATE USER $mysql_user@localhost IDENTIFIED BY '$mysql_pass'" | mysql -u root --password="$mysql_root_pass"
echo "GRANT ALL PRIVILEGES ON \`openvpn-admin\`.*  TO $mysql_user@localhost" | mysql -u root --password="$mysql_root_pass"
echo "FLUSH PRIVILEGES" | mysql -u root --password="$mysql_root_pass"
echo "SET GLOBAL time_zone = '$gmt_offset';" | mysql -u root --password="$mysql_root_pass"
systemctl restart mysql
echo -e "${Green}Setup Web Application${NC}"

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

# Replace in the client configurations with the ip of the server and openvpn protocol
for file in $(find -name client.ovpn); do
    sed -i "s/remote xxx\.xxx\.xxx\.xxx 1194/remote $public_ip $server_port/" $file
    sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $public_ip $server_port/" $file
    echo "<ca>" >> $file
    cat "/etc/openvpn/ca.crt" >> $file
    echo "</ca>" >> $file
    echo "<tls-auth>" >> $file
    cat "/etc/openvpn/ta.key" >> $file
    echo "</tls-auth>" >> $file

  if [ $openvpn_proto = "udp" ]; then
    sed -i "s/proto tcp-client/proto udp/" $file
  fi
done

# Copy ta.key inside the client-conf directory
for directory in "./client-conf/gnu-linux/" "./client-conf/osx-viscosity/" "./client-conf/windows/"; do
  cp "/etc/openvpn/"{ca.crt,ta.key} $directory
done

# Install third parties
bower --allow-root install
chown -R "$user:$group" "$openvpn_admin"

echo -e "${Green}Setting Apache Configuration${NC}"
# finding PHP version (major and minor only as OS uses x.x format in /etc/php folder)
php_version=$(php -v | head -n1 | cut -f2 -d\ | cut -f1,2 -d.)

cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/openvpn.conf
sed -i 's/\/var\/www\/html/\/var\/www\/openvpn-admin/g' /etc/apache2/sites-available/openvpn.conf
sed -i '/<\/VirtualHost>/i \\n\t<Directory \/var\/www\/openvpn-admin>\n\t\tOptions Indexes FollowSymLinks\n\t\tAllowOverride All\n\t\tRequire all granted\n\t<\/Directory>' /etc/apache2/sites-available/openvpn.conf
sed -i "/;date.timezone =/a date.timezone = $timezone ; added by openvpn-admin" /etc/php/$php_version/apache2/php.ini
#touch /var/www/.htpasswd
#chown www-data:www-data /var/www/.htpasswd
#echo -e "${Yellow}It's time to secure client configuration folder from anonymous browser and assign a super admin user to be only able to browse it.\n"
#echo -e "This username / password will only applies to http://your-site/client-config and all sub directories\n${NC}"
#read -p "Client Configuration Web Access Username: " client_folder_username
#htpasswd /var/www/.htpasswd $client_folder_username
a2dissite 000-default
a2ensite openvpn
systemctl restart apache2

echo -e "${Green}Finalizing OpenVPN Configuration${NC}"
#sed -i 's/explicit-exit-notify 1/# explicit-exit-notify 1/g' /etc/openvpn/server.conf
#sed -i 's/80.67.169.12/8.8.8.8/g' /etc/openvpn/server.conf
#sed -i 's/80.67.169.40/8.8.4.4/g' /etc/openvpn/server.conf
if [ -z "$company_name" ]
then
  company_name="VPN"
else
  sed -i "s/VPN/$company_name/" /var/www/openvpn-admin/client-conf/windows/filename
fi
truncate -s -1 /var/www/openvpn-admin/client-conf/windows/filename
systemctl start openvpn@server

echo "Auto Generated MySQL Root Password: $mysql_root_pass" >> ~/OpenVPN_Creds
echo "Auto Generated OpenVPN-Admin MySQL Username: $mysql_user" >> ~/OpenVPN_Creds
echo "Auto Generated OpenVPN-Admin MySQL Password: $mysql_pass" >> ~/OpenVPN_Creds
echo -e "\n\n\n${Yellow}"
echo -e "################################################################################"
echo -e "################################### Finished ###################################"
echo
echo -e "${Green}Congratulations, you have successfully setup OpenVPN-Admin!${NC}"
echo
echo -e "Finish the install by going to: ${Red}"
echo -e "             http://$ip_server/index.php?installation${NC}"
echo -e "After install, Access GUI at: ${Red}"
echo -e "             http://$ip_server/${NC}"
echo
echo -e "Here are more details:"
echo -e "             Your Public URL: ${Red}http://$public_ip"
echo
echo -e "	We recommend only forward UDP port 1194 if you are behind a firewall"
echo -e "	Publishing TCP port 80 over the web is a high risk and NOT recommended${NC}"
echo
echo -e "             Auto Generated MySQL Root Password: ${Red}$mysql_root_pass ${NC}" 
echo -e "             Auto Generated OpenVPN-Admin MySQL Username: ${Red}$mysql_user ${NC}"
echo -e "             Auto Generated OpenVPN-Admin MySQL Password: ${Red}$mysql_pass ${Yellow}"
echo
echo -e "	Credentials are saved in /root/OpenVPN_Creds file for future refrence."
echo
echo -e "             Selected download file name: ${Red}$company_name.ovpn ${NC}"
echo
echo -e " Please, report any issues here https://github.com/arvage/OpenVPN-Admin (Armin Gorji)"
echo
echo -e "${Yellow}################################################################################${NC}"
echo -e "${Yellow}################################################################################${NC}"

systemctl restart openvpn@server
