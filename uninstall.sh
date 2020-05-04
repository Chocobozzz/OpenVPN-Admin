#!/bin/bash

print_help () {
  echo -e "./desinstall.sh www_basedir"
  echo -e "\tbase_dir: The place where the web application is in"
}

# Ensure to be root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Ensure there are enought arguments
if [ "$#" -ne 1 ]; then
  print_help
  exit
fi

www="$1/openvpn-admin"

if [ ! -d "$www" ]; then
  print_help
  exit
fi

# Get root pass (to delete the database and the user)
mysql_root_pass=""
status_code=1

while [ $status_code -ne 0 ]; do
  read -p "MySQL root password: " -s mysql_root_pass; echo
  echo "SHOW DATABASES" | mysql -u root --password="$mysql_root_pass" &> /dev/null
  status_code=$?
done

mysql_user=$(sed -n "s/^.*user = '\(.*\)'.*$/\1/p" "$www/include/config.php")

if [ "$mysql_user" = "" ]; then
  echo "Can't find the MySQL user. Please ensure your include/config.php is well structured or report an issue"
  exit
fi

echo -e "\033[1mAre you sure to completely delete OpenVPN configurations, the web application (with the MySQL user/database) and the iptables rules? (yes/*)\033[0m"
read agree

if [ "$agree" != "yes" ]; then
  exit
fi

# MySQL delete
echo "DROP USER $mysql_user@localhost" | mysql -u root --password="$mysql_root_pass"
echo "DROP DATABASE \`openvpn-admin\`" | mysql -u root --password="$mysql_root_pass"

# Files delete (openvpn confs/keys + web application)
rm -r /etc/openvpn/easy-rsa/
rm -r /etc/openvpn/{ccd,scripts,server.conf,ca.crt,ta.key,server.crt,server.key,dh*.pem}
rm -r "$www"

# Remove rooting rules
echo 0 > "/proc/sys/net/ipv4/ip_forward"
sed -i '/net.ipv4.ip_forward = 1/d' '/etc/sysctl.conf'

iptables -D FORWARD -i tun0 -j ACCEPT
iptables -D FORWARD -o tun0 -j ACCEPT
iptables -D OUTPUT -o tun0 -j ACCEPT

iptables -D FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -D POSTROUTING -s 10.8.0.2/24 -o eth0 -j MASQUERADE


sed -i "/added by openvpn-admin/d" /etc/php/7.3/apache2/php.ini
echo "The application has been completely removed!"
