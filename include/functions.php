<?php

  function getMigrationSchemas() {
    return [ 0, 5 ];
  }

  function updateSchema($bdd, $newKey) {
    if ($newKey === 0) {
      $req_string = 'INSERT INTO `application` (sql_schema) VALUES (?)';
    }
    else {
      $req_string = 'UPDATE `application` SET `sql_schema` = ?';
    }

    $req = $bdd->prepare($req_string);
    $req->execute(array($newKey));
  }

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
    //return true when login is OK.
    return true;
  }
  else
  {
    //return false when login is NOK
    return false;
  }
}

//get all LDAP users and place them inside a database.
function getLDAPUsers()
{

}

?>
