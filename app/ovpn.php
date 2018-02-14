<?php

$_ovpn = new EvilFreelancer\OpenVPN();

$_ovpn
    ->addParam('client')
    ->addParam('dev', getenv('VPN_DEV'))
    ->addParam('proto', getenv('VPN_PROTO'))
    ->addParam('remote', getenv('VPN_REMOTE'))
    ->addParam('port', getenv('VPN_REMOTE_PORT'))
    ->addParam('resolv-retry', 'infinite')
    ->addParam('cipher', 'AES-256-CBC')
    ->addParam('redirect-gateway')
    ->addParam('key-direction', 1)
    ->addParam('remote-cert-tls', 'server')
    ->addParam('auth-user-pass')
    ->addParam('auth-nocache')
    ->addParam('nobind')
    ->addParam('persist-key')
    ->addParam('persist-tun')
    ->addParam('comp-lzo')
    ->addParam('verb', 3);

$_ovpn
    ->addCert('ca', getenv('VPN_CONF') . '/ca.crt', true)
    ->addCert('tls-auth', getenv('VPN_CONF') . '/ta.key', true);

$config = $_ovpn->generateConfig();

switch ($_POST['configuration_os']) {
    case 'gnu_linux':
    case 'configuration_os':
        $filename = 'client.conf';
        break;
    default:
        $filename = 'client.ovpn';
        break;
}

header('Content-Type:text/plain');
header("Content-Disposition: attachment; filename=$filename");
header("Pragma: no-cache");
header("Expires: 0");

die("$config");
