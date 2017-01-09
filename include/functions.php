<?php

  function printError($str) {
    echo '<div class="alert alert-danger" role="alert">' . $str . '</div>';
  }

  function printSuccess($str) {
    echo '<div class="alert alert-success" role="alert">' . $str . '</div>';
  }

  function isInstalled($bdd) {
    $req = $bdd->prepare("SHOW TABLES LIKE 'admin'");
    $req->execute();

    if(!$req->fetch())
      return false;

    return true;
  }

  function hashPass($pass) {
    return password_hash($pass, PASSWORD_DEFAULT);
  }

  function passEqual($pass, $hash) {
    return password_verify($pass, $hash);
  }

//login with LDAP

function loginLDAP($serverFQDN, $username, $password)
{
  //connect to LDAP server or AD server. Both work
  $ldap = ldap_connect($serverFQDN);
  //check if user exists  if works return true if not return false
  if ($bind = ldap_bind($ldap, $username, $password))
  {
    return true;
  }
  else
  {
    return false;
  }
}

?>
