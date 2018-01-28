<?php
  require(dirname(__FILE__) . "/config.php");

	$options[PDO::ATTR_ERRMODE] = PDO::ERRMODE_EXCEPTION;
	$bdd = new PDO("mysql:host=$host;port=$port;dbname=$db", $user, $pass, $options);
?>
