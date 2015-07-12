#!/bin/bash

print_help () {
  echo -e "./update.sh www_basedir"
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

base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

user=$(ls -l "$www/include/config.php" | awk '{ print $3 }')
group=$(ls -l "$www/include/config.php" | awk '{ print $4 }')


rm -r "${www:?}/"{index.php,bower.json,.bowerrc,js,include/html,include/connect.php,include/functions.php,include/grids.php,css}

cp -r "$base_path/"{index.php,bower.json,.bowerrc,js,css} "$www"
cp -r "$base_path/include/"{html,connect.php,functions.php,grids.php} "$www/include"

cd "$www"

bower --allow-root install
chown -R "$user:$group" "$www"
