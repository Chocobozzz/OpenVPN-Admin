#!/bin/bash
NC='\033[0m'            # No Color
Red='\033[1;31m'        # Light Red
Yellow='\033[0;33m'     # Yellow
Green='\033[0;32m'      # Green
clear
echo -e "${Green}Updating and Getting Ready${Yellow}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git
cd ~
echo -e "${Red}"
git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
echo -e "${NC}"

chmod +x ./install.sh
clear
echo -e "${Yellow}Now run below commands:"
echo
echo -e "${Green}cd openvpn-admin"
echo -e "sudo ./install.sh /var/www www-data www-data${NC}"
echo
