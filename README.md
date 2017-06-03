# OpenVPN Admin

## Summary
Administrate its OpenVPN with a web interface (logs visualisations, users managing...) and a SQL database.

![Previsualisation configuration](https://lutim.cpy.re/fUq2rxqz)
![Previsualisation administration](https://lutim.cpy.re/wwYMkHcM)


## Prerequisite

  * GNU/Linux with Bash and root access
  * Fresh install of OpenVPN
  * Web server (NGinx, Apache...)
  * MySQL
  * PHP >= 5.5 with modules:
    * zip
    * pdo_mysql
  * bower
  * unzip
  * wget
  * sed
  * curl

### Debian Jessie

````
# apt-get install openvpn apache2 php7.0-mysql mysql-server php7.0 nodejs unzip git wget sed npm curl zip libapache2-mod-php
# npm install -g bower
# ln -s /usr/bin/nodejs /usr/bin/node
````

### CentOS 7

````
# yum install epel-release
# yum install openvpn httpd php-mysql mariadb-server php nodejs unzip git wget sed npm
# npm install -g bower
# systemctl enable mariadb
# systemctl start mariadb
````

### Other distribution... (PR welcome)

## Tests

Only tested on Debian Jessie. Feel free to open issues.

## Installation

  * Setup OpenVPN and the web application:

        $ cd ~/my_coding_workspace
        $ git clone https://github.com/modfiles/OpenVPN-Admin openvpn-admin
        $ cd openvpn-admin
        # ./install.sh www_base_dir web_user web_group
		
		Sample input
		# sudo ./install.sh /var/www/html/ nobody nogroup

  * Setup the web server (Apache, NGinx...) to serve the web application.
  * Guide in Apache2 configuration on Ubuntu 16.04
https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-16-04
  * Create the admin of the web application by visiting `http://your-installation/index.php?installation`

## Usage

  * Start OpenVPN on the server (for example `systemctl start openvpn@server`)
  * Connect to the web application as an admin
  * Create an user
  * User get the configurations files via the web application (and put them in */etc/openvpn*)
  * Users on GNU/Linux systems, run `chmod +x /etc/openvpn/update-resolv.sh` as root
  * User run OpenVPN (for example `systemctl start openvpn@client`)

## Update

    $ git pull origin master
    # ./update.sh www_base_dir
	
	Sample input
	sudo ./update.sh /var/www/html/

## Desinstall
It will remove all installed components (OpenVPN keys and configurations, the web application, iptables rules...).

    # ./desinstall.sh www_base_dir
	
	Sample input
	sudo ./desinstall.sh /var/www/html/

## Use of

  * [Bootstrap](https://github.com/twbs/bootstrap)
  * [Bootstrap Table](http://bootstrap-table.wenzhixin.net.cn/)
  * [Bootstrap Datepicker](https://github.com/eternicode/bootstrap-datepicker)
  * [JQuery](https://jquery.com/)
  * [X-editable](https://github.com/vitalets/x-editable)
