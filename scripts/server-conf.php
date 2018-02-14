<?php
// Enable dotEnv support
require_once __DIR__ . '/../vendor/autoload.php';
$dotenv = new Dotenv\Dotenv(__DIR__ . '/../');
if (file_exists(__DIR__ . '/../.env')) $dotenv->load();

$_ovpn = new EvilFreelancer\OpenVPN();

// TCP or UDP, port 443, tunneling
$_ovpn
    ->addParam('mode', 'server')
    ->addParam('tls-server')
    ->addParam('dev', getenv('VPN_DEV'))
    ->addParam('proto', getenv('VPN_PROTO'))
    ->addParam('port', getenv('VPN_LOCAL_PORT'));

// If listening address is set
if (!empty(getenv('VPN_LOCAL')))
    $_ovpn->addParam('local', getenv('VPN_LOCAL'));

// KEY, CERTS AND NETWORK CONFIGURATION
$_ovpn
    ->addCert('ca', getenv('VPN_CONF') . '/ca.crt')
    ->addCert('cert', getenv('VPN_CONF') . '/server.crt')
    ->addCert('key', getenv('VPN_CONF') . '/server.key')
    ->addCert('dh', getenv('VPN_CONF') . '/dh.pem')
    ->addCert('tls-auth', getenv('VPN_CONF') . '/ta.key')
    ->addParam('key-direction', 0)
    ->addParam('cipher', 'AES-256-CBC')
    ->addParam('server', trim(getenv('VPN_SERVER'),'"'))
    ->addPush('redirect-gateway def1')
    ->addPush('dhcp-option DNS 8.8.8.8')
    ->addPush('dhcp-option DNS 8.8.4.4')
    ->addParam('keepalive', '10 120')
    ->addParam('reneg-sec', '18000');

// SECURITY
$_ovpn
    ->addParam('user', getenv('VPN_USER'))
    ->addParam('group', getenv('VPN_GROUP'))
    ->addParam('persist-key')
    ->addParam('persist-tun')
    ->addParam('comp-lzo');

// LOG
$_ovpn
    ->addParam('verb', 3)
    ->addParam('mute', 20)
    ->addParam('status', '/var/log/openvpn/status.log')
    ->addParam('log-append', '/var/log/openvpn/openvpn.log')
    ->addParam('client-config-dir', 'ccd');

// PASS
$_ovpn
    ->addParam('script-security', 3)
    ->addParam('username-as-common-name')
    ->addParam('verify-client-cert', 'none')
    ->addParam('max-clients', '50')
    ->addParam('auth-user-pass-verify', getenv('SCRIPTS_LOGIN') . ' via-env')
    ->addParam('client-connect', getenv('SCRIPTS_CONNECT'))
    ->addParam('client-disconnect', getenv('SCRIPTS_DISCONNECT'));

$config = $_ovpn->generateConfig();

die("$config");
