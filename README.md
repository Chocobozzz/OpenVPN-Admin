## Raspberry Pi OpenVPN Admin using Apache2 

## Summary
Administrate its OpenVPN with a web interface (logs visualisations, users managing...) and a SQL database.

![Previsualisation configuration](https://lutim.cpy.re/fUq2rxqz)
![Previsualisation administration](https://lutim.cpy.re/wwYMkHcM)


## Prerequisite

  * Raspbian with Bash access or remote SSH
  * Git

## Tests

Only tested on Raspberry Pi 3 with Raspbian Buster (No GUI).

## Installation
  * for online automated install
      wget -O - https://raw.githubusercontent.com/arvage/OpenVPN-Admin/master/online-install.sh | bash

  * Setup OpenVPN and the web application:

        sudo apt update
        sudo apt install -y git
        cd ~
        git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
        cd openvpn-admin
        sudo ./install.sh /var/www www-data www-data

  * If you are using any other web server than Apache like NGinx, you need to set it up manually to serve the web application.
  * Once the installation is finished browse to `http://your_hostname_or_ip/index.php?installation` to create your admin user.

## Usage

  * Connect to the web application as an admin
  * Create an user
  * User get the configurations files via the web application (and put them in */etc/openvpn*)
  * Users on GNU/Linux systems, run `chmod +x /etc/openvpn/update-resolv.sh` as root
  * User run OpenVPN (for example `systemctl start openvpn@client`)

## Update

    git pull origin master
    ./update.sh /var/www

## Desinstall
It will remove all installed components (OpenVPN keys and configurations, the web application, iptables rules...).

    sudo ./desinstall.sh /var/www

## Use of

  * [Bootstrap](https://github.com/twbs/bootstrap)
  * [Bootstrap Table](http://bootstrap-table.wenzhixin.net.cn/)
  * [Bootstrap Datepicker](https://github.com/eternicode/bootstrap-datepicker)
  * [JQuery](https://jquery.com/)
  * [X-editable](https://github.com/vitalets/x-editable)
