## Raspberry Pi OpenVPN Admin using LAMP

## Summary
Administer OpenVPN Server with a web interface (Users Management, Logs, Visualizations)


## Prerequisite

  * Raspbian with Bash access or remote SSH
  * Git

## Installation

  * Method 1:
  
        wget -O - https://raw.githubusercontent.com/arvage/OpenVPN-Admin/master/online-install.sh | bash
        
  * Method 2:

        sudo apt update
        sudo apt install -y git
        cd ~
        git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
        cd openvpn-admin
        sudo ./install.sh /var/www www-data www-data

  * If you are using any other web server than Apache like NGinx, you need to set it up manually to serve the web application.
  * Once the installation is finished browse to `http://your_hostname_or_ip/index.php?installation` to create your admin user.

## Tests

Only tested on Raspberry Pi 3 with Raspbian Buster (No GUI).

## Usage

  * Connect to the web application as an admin
  * Create an user
  * User get the configurations files via the web application (and put them in */etc/openvpn*)
  * Users on GNU/Linux systems, run `chmod +x /etc/openvpn/update-resolv.sh` as root
  * User run OpenVPN (for example `systemctl start openvpn@client`)

## Update

    git pull origin master
    ./update.sh /var/www

## Uninstall
It will remove all installed components (OpenVPN keys and configurations, the web application, iptables rules...).

    sudo ./uninstall.sh /var/www

## Use of

  * [Bootstrap](https://github.com/twbs/bootstrap)
  * [Bootstrap Table](http://bootstrap-table.wenzhixin.net.cn/)
  * [Bootstrap Datepicker](https://github.com/eternicode/bootstrap-datepicker)
  * [JQuery](https://jquery.com/)
  * [X-editable](https://github.com/vitalets/x-editable)
