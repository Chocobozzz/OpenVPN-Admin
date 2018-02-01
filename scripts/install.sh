#!/bin/bash

print_help () {
    echo -e "./install.sh www_basedir user group (eg /var/www/openvpn-admin)"
    echo -e "\tbase_dir: The place where the web application will be put in"
    echo -e "\tuser:     User of the web application"
    echo -e "\tgroup:    Group of the web application"
    exit
}

print_error() {
    echo "$1"
    exit
}

# Ensure to be root
if [ "$EUID" -ne 0 ]; then
  print_error "Please run as root"
fi

# Ensure there are enought arguments
if [ "$#" -ne 3 ]; then
  print_help
fi

# Ensure there are the prerequisites
for i in openvpn mysql php node npm unzip wget sed curl; do
  which $i > /dev/null
  if [ "$?" -ne 0 ]; then
    print_error "Miss $i"
  fi
done

www=$1
user=$2
group=$3

openvpn_admin="$www"

# Check the validity of the arguments
if [ ! -d "$www" ] ||  ! grep -q "$user" "/etc/passwd" || ! grep -q "$group" "/etc/group" ; then
  print_help
  exit
fi

base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Read dotEnv file
source "$base_path/../.env"

source "$base_path/install/00_env.sh"
source "$base_path/install/01_mysql.sh"
source "$base_path/install/02_app.sh"
source "$base_path/install/03_certificate.sh"
source "$base_path/install/04_openvpn.sh"
source "$base_path/install/05_firewall.sh"

printf "\033[1m\n#################################### Finish ####################################\n"

echo -e "# Congratulations, you have successfully setup OpenVPN-Admin! #\r"
echo -e "Please, finish the installation by configuring your web server (Apache, Nginx...)"
echo -e "and install the web application by visiting http://your-installation/index.php?installation\r"
echo -e "Then, you will be able to run OpenVPN with systemctl start openvpn@server\r"
echo "Please, report any issues here https://github.com/Chocobozzz/OpenVPN-Admin"

printf "\n################################################################################ \033[0m\n"
