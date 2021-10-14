#!/bin/bash
NC='\033[0m'            # No Color
Red='\033[1;31m'        # Light Red
Yellow='\033[0;33m'     # Yellow
Green='\033[0;32m'      # Green
clear
echo -e "${Green}Updating and Getting Ready${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git
cd ~
git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
cd openvpn-admin
chmod +x ./install.sh
sudo ./install.sh /var/www www-data www-data
