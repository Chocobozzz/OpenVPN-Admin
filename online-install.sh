#!/bin/bash
NC='\033[0m'            # No Color
Red='\033[1;31m'        # Light Red
Yellow='\033[0;33m'     # Yellow
Green='\033[0;32m'      # Green
clear
OS=$(cat /etc/os-release | grep PRETTY_NAME | sed 's/"//g' | cut -f2 -d= | cut -f1 -d " ") # Don't change this unless you know what you're doing
if [[ "$OS" != "Ubuntu" ]]; then
  echo -e "${Red}Oops! Only Ubuntu and Raspbian OS are supported.${NC}"
  exit
elif [[ "$OS" != "Raspbian" ]]; then
  echo -e "${Red}Oops! Only Ubuntu and Raspbian OS are supported.${NC}"
  exit
fi
echo -e "${Green}Updating and Getting Ready${Yellow}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git
cd ~
echo -e "${Red}"
git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
echo -e "${NC}"
cd openvpn-admin
chmod +x ./install.sh
sudo ./install.sh /var/www www-data www-data
