## Raspberry Pi OpenVPN Admin (Tested on Ubuntu and Raspbian using Apache2)

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
  * node
  * npm

### Raspbian Buster, Ubuntu 20 (Focal Fossa) and Debian 10

Skip to "Installation" section 

### Debian 9 Stretch

In order to install `npm`, [stretch-backports need to be added to your sources.list](https://backports.debian.org/Instructions/#index2h2).

````
# apt-get install -t stretch-backports npm nodejs
# apt-get install openvpn apache2 php-mysql mysql-server php-zip php unzip git wget sed curl
# npm install -g bower
````


### Debian 8 Jessie

````
# apt-get install openvpn apache2 php5-mysql mysql-server php5 nodejs unzip git wget sed npm curl
# npm install -g bower
# ln -s /usr/bin/nodejs /usr/bin/node
````


### Other distribution... (PR welcome)

not supported and tested

## Tests

Only tested on Ubuntu 20.04 LTS (Focal Fossa) and Raspbian Buster. Feel free to open issues.



## Installation

  * Setup OpenVPN and the web application:

        $ sudo apt update
        $ sudo apt install -y git
        $ cd ~
        $ git clone https://github.com/arvage/OpenVPN-Admin openvpn-admin
        $ cd openvpn-admin
        # sudo ./install.sh /var/www www-data www-data

  * If you are using any other web server than Apache like NGinx, you need to set it up manually to serve the web application.
  * Once the installation is finished browse to `http://your_hostname_or_ip/index.php?installation` to create your admin user.

## Usage

  * Connect to the web application as an admin
  * Create an user
  * User get the configurations files via the web application (and put them in */etc/openvpn*)
  * Users on GNU/Linux systems, run `chmod +x /etc/openvpn/update-resolv.sh` as root
  * User run OpenVPN (for example `systemctl start openvpn@client`)

## Update

    $ git pull origin master
    # ./update.sh /var/www

## Desinstall
It will remove all installed components (OpenVPN keys and configurations, the web application, iptables rules...).

    # sudo ./desinstall.sh /var/www

## Use of

  * [Bootstrap](https://github.com/twbs/bootstrap)
  * [Bootstrap Table](http://bootstrap-table.wenzhixin.net.cn/)
  * [Bootstrap Datepicker](https://github.com/eternicode/bootstrap-datepicker)
  * [JQuery](https://jquery.com/)
  * [X-editable](https://github.com/vitalets/x-editable)
