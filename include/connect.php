<?php
  #require(dirname(__FILE__) . "/config.php");
  
  
  
	//set timezone
	date_default_timezone_set('Europe/London');

	//database credentials
	define('DBHOST','localhost');
	define('DBUSER','root');
	define('DBPASS','password');
	define('DBNAME','openvpn_admin');
	define('DBPORT','3306');
	
	
/* 	
try {

	//create PDO connection
	$bdd = new PDO("mysql:host=".DBHOST.";charset=utf8mb4;".DBPORT.";dbname=".DBNAME, DBUSER, DBPASS);
    //$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_SILENT);//Suggested to uncomment on production websites
    $bdd->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);//Suggested to comment on production websites
    $bdd->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

} catch(PDOException $e) {
	//show error
    echo '<p class="bg-danger">'.$e->getMessage().'</p>';
    exit;
}
 */
	$bdd = new PDO("mysql:host=".DBHOST.";charset=utf8mb4;port=".DBPORT.";dbname=".DBNAME, DBUSER, DBPASS);
    //$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_SILENT);//Suggested to uncomment on production websites
    $bdd->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);//Suggested to comment on production websites
    $bdd->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
 
?>
