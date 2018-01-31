<?php

$_ovpn = new EvilFreelancer\OpenVPN();

$_ovpn->dev = getenv('VPN_INIF');
$_ovpn->proto = getenv('VPN_PROTO');
$_ovpn->port = getenv('VPN_PORT');
$_ovpn->remote = getenv('VPN_REMOTE');
$_ovpn->resolvRetry = 'infinite';
$_ovpn->cipher = 'AES-256-CBC';
$_ovpn->redirectGateway = true;

$_ovpn->addCert('ca', getenv('VPN_CONF') . '/ca.crt', true)
->addCert('tls-auth', getenv('VPN_CONF') . '/ta.key', true);

$_ovpn->keyDirection = 1;
$_ovpn->remoteCertTls = 'server';
$_ovpn->authUserPass = true;
$_ovpn->authNocache = true;

$_ovpn->nobind = true;
$_ovpn->persistKey = true;
$_ovpn->persistTun = true;
$_ovpn->compLzo = true;
$_ovpn->verb = 3;

$config = $_ovpn->getClientConfig();

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