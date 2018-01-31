#!/bin/bash

print_error() {
    echo "$1"
    exit
}

# Ensure to be root
if [ "$EUID" -ne 0 ]; then
  print_error "Please run as root"
fi

base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Read dotEnv file
source "$base_path/../.env"

source "$base_path/install/00_env.sh"
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
