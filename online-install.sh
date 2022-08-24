#!/bin/bash
NC='\033[0m'            # No Color
Red='\033[1;31m'        # Light Red
Yellow='\033[0;33m'     # Yellow
Green='\033[0;32m'      # Green
clear
echo '.-----------------------------------------------------------------------------.'
echo '||Es| |F1 |F2 |F3 |F4 |F5 | |F6 |F7 |F8 |F9 |F10|                  C= AMIGA   |'
echo '||__| |___|___|___|___|___| |___|___|___|___|___|                             |'
echo '| _____________________________________________     ________    ___________   |'
echo '||~  |! |" |§ |$ |% |& |/ |( |) |= |? |` || |<-|   |Del|Help|  |{ |} |/ |* |  |'
echo '||`__|1_|2_|3_|4_|5_|6_|7_|8_|9_|0_|ß_|´_|\_|__|   |___|____|  |[ |]_|__|__|  |'
echo '||<-  |Q |W |E |R |T |Z |U |I |O |P |Ü |* |   ||               |7 |8 |9 |- |  |'
echo '||->__|__|__|__|__|__|__|__|__|__|__|__|+_|_  ||               |__|__|__|__|  |'
echo "||Ctr|oC|A |S |D |F |G |H |J |K |L |Ö |Ä |^ |<'|               |4 |5 |6 |+ |  |"
echo '||___|_L|__|__|__|__|__|__|__|__|__|__|__|#_|__|       __      |__|__|__|__|  |'
echo '||^    |> |Y |X |C |V |B |N |M |; |: |_ |^     |      |A |     |1 |2 |3 |E |  |'
echo '||_____|<_|__|__|__|__|__|__|__|,_|._|-_|______|    __||_|__   |__|__|__|n |  |'
echo '|   |Alt|A  |                       |A  |Alt|      |<-|| |->|  |0    |. |t |  |'
echo '|   |___|___|_______________________|___|___|      |__|V_|__|  |_____|__|e_|  |'
echo '|                                                                             |'
echo '`-----------------------------------------------------------------------------.'

OS=$(cat /etc/os-release | grep PRETTY_NAME | sed 's/"//g' | cut -f2 -d= | cut -f1 -d " ") # Don't change this unless you know what you're doing
if [ "$OS" == "Ubuntu" ] || [ "$OS" == "Raspbian" ]; 
then
  :
else
  echo -e "${Red}Oops! Only Ubuntu and Raspbian OS are supported.${NC}"
  exit
fi
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

echo -e "${Green}Updating and Getting Ready${Yellow}"
DEBIAN_FRONTEND=noninteractive sudo apt-get update && sudo apt-get upgrade -y -q
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y git mc
cd ~
echo -e "${Red}"
git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
echo -e "${NC}"
cd openvpn-admin
chmod +x ./install.sh
sudo ./install.sh /var/www www-data www-data
