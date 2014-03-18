<?php
    require(dirname(__FILE__) . "/config.php");

	$options[PDO::ATTR_ERRMODE] = PDO::ERRMODE_EXCEPTION;
	$bdd = new PDO("mysql:host=$hote;port=$port;dbname=$bd", $utilisateur, $mdp, $options);
?>
