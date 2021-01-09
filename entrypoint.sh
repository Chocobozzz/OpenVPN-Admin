#!/bin/bash

if [ ! -f "/etc/openvpn/.install-finish" ]; then
  /opt/openvpn-admin/install-docker.sh
fi

printf "\n################## Setup Web Config ##################\n"

wwwdata="/var/www/html"

# New workspace
cd "${wwwdata}"

# Replace config.php variables
sed -i "s/\$host = 'localhost';/\$host = 'db';/" "./include/config.php"
sed -i "s/\$user = '';/\$user = 'root';/" "./include/config.php"
sed -i "s/\$pass = '';/\$pass = '${mysql_root_pass}';/" "./include/config.php"

# Replace in the client configurations with the ip of the server and openvpn protocol
for file in $(find -name client.ovpn); do
    sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote ${server_address} ${openvpn_port}/" $file
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

# Modify http owner
chown -R "www-data:www-data" "${wwwdata}"

echo "Startup finished."
php-fpm -D
nginx -g 'daemon off;'