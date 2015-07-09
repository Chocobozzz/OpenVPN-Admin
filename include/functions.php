<?php
  
  function dateToSql($date) {
    return implode('-', array_reverse(explode('/', $date)));
  }
  
  function dateFromSql($date) {
    return implode('/', array_reverse(explode('-', $date)));
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
  
?>