#!/bin/bash
clear
echo -e "${Green}Updating and Getting Ready"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git
cd ~
git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
cd openvpn-admin
chmod +x ./install.sh
sudo ./install.sh /var/www www-data www-data
