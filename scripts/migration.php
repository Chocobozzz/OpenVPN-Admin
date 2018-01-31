<?php

if (count($argv) !== 2) {
    echo "Need the www base path as argument";
    exit(0);
}

$www = $argv[1];

require("$www/app/config.php");
require("$www/app/connect.php");
require("$www/app/functions.php");

$migrations = getMigrationSchemas();

try {
    $req = $bdd->prepare('SELECT `sql_schema` FROM `application` LIMIT 1');
    $req->execute();
    $data = $req->fetch();

    $sql_schema = -1;
    if ($data['sql_schema']) {
        $sql_schema = $data['sql_schema'];
    }
} // Table does not exist
catch (Exception $e) {
    $sql_schema = -1;
}

// For each migrations
foreach ($migrations as $migration_value) {

    // Do the migration, we are behind the last schema
    if ($sql_schema < $migration_value) {

        // Create the tables or die
        $sql_file = dirname(__FILE__) . "/sql/schema-$migration_value.sql";
        try {
            $sql = file_get_contents($sql_file);
            $bdd->exec($sql);
        } catch (PDOException $e) {
            printError($e->getMessage());
            exit(1);
        }

        // Update schema to the new value
        updateSchema($bdd, $migration_value);

        echo "Moved to schema $migration_value\n";
    }
}
