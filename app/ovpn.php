client
dev <?php echo $vpn_dev . "\n" ?>
proto <?php echo $vpn_proto ?>-client
remote <?php echo $vpn_remote . "\n" ?>
resolv-retry infinite
cipher AES-256-CBC
redirect-gateway

# Keys
ca       [inline]
<?php echo file_get_contents("/etc/openvpn/ca.crt") . "\n" ?>
tls-auth [inline] 1
<?php echo file_get_contents("/etc/openvpn/ta.key") . "\n" ?>

key-direction 1
remote-cert-tls server
auth-user-pass
auth-nocache

# Security
nobind
persist-key
persist-tun
comp-lzo
verb 3

# Proxy ?
# http-proxy cache.univ.fr 3128
