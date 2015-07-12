# OpenVPN Admin

## Summary
Administrate its OpenVPN with a web interface (logs visualisations, users managing...) and a SQL database.

![Previsualisation](http://lutim.cpy.re/wRzijuCg)

## Prerequisite

  * GNU/Linux with Bash and root access
  * Fresh install of OpenVPN
  * Web server (NGinx, Apache...)
  * MySQL
  * PHP >= 5.5 with modules:
    * zip
    * pdo_mysql
  
## Tests

Only tested on Debian Jessie. Feel free to open issues.

## Installation

  * Setup OpenVPN and the web application:

        $ cd ~/my_coding_workspace
        $ git clone https://github.com/Chocobozzz/OpenVPN-Admin openvpn-admin
        $ cd openvpn-admin
        # ./install.sh www_base_dir web_user web_group

  * Setup the web server (Apache, NGinx...) to serve the web application.
  * Create the admin of the web application by visiting http://your-installation/index.php?installation

## Usage

  * Start OpenVPN on the server (for example `systemctl start openvpn@server`)
  * Connect to the web application as an admin
  * Create an user
  * User get the configurations files via the web application
  * User run OpenVPN (for example `systemctl start openvpn@client`)

## Update

    $ git pull origin master
    # ./update.sh www_base_dir
    
## Desinstall
It will remove all installed components (OpenVPN keys and configurations, the web application, iptables rules...).

    # ./clean.sh www_base_dir

## Use of

  * [Bootstrap](https://github.com/twbs/bootstrap)
  * [SlickGrid](https://github.com/mleibman/SlickGrid)
  * [SlickGridEnhancementPager](https://github.com/kingleema/SlickGridEnhancementPager) ([forked](https://github.com/Chocobozzz/SlickGridEnhancementPager/))
  * [js-sha1](https://github.com/emn178/js-sha1)
