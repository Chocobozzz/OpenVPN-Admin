<?php
    require(basename(__FILE__) . "/config.php");

	$pdo_options[PDO::ATTR_ERRMODE] = PDO::ERRMODE_EXCEPTION;
	$bdd = new PDO("mysql:host='.$hote.';port='.$port.';dbname='.$bd, $utilisateur, $mdp, $options);
?>
