<?php
// Enable dotEnv support
require_once __DIR__ . '/../vendor/autoload.php';
$dotenv = new Dotenv\Dotenv(__DIR__ . '/../');
if (file_exists(__DIR__ . '/../.env')) $dotenv->load();

session_start();

require(dirname(__FILE__) . '/../app/functions.php');
require(dirname(__FILE__) . '/../app/connect.php');

// Disconnecting ?
if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: .");
    exit(-1);
}

// Get the configuration files ?
if (isset($_POST['configuration_get'], $_POST['configuration_username'], $_POST['configuration_pass'], $_POST['configuration_os'])
    && !empty($_POST['configuration_pass'])) {
    $req = $bdd->prepare('SELECT * FROM user WHERE user_id = ?');
    $req->execute(array($_POST['configuration_username']));
    $data = $req->fetch();

    // Error ?
    if ($data && passEqual($_POST['configuration_pass'], $data['user_pass'])) {
        $vpn_dev = getenv('VPN_INIF');
        $vpn_proto = getenv('VPN_PROTO');
        $vpn_remote = getenv('VPN_REMOTE'). ' ' . getenv('VPN_PORT');

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

        require(dirname(__FILE__) . '/../app/ovpn.php');
        die();
    } else {
        $error = true;
    }
} // Admin login attempt ?
else if (isset($_POST['admin_login'], $_POST['admin_username'], $_POST['admin_pass']) && !empty($_POST['admin_pass'])) {

    $req = $bdd->prepare('SELECT * FROM admin WHERE admin_id = ?');
    $req->execute(array($_POST['admin_username']));
    $data = $req->fetch();

    // Error ?
    if ($data && passEqual($_POST['admin_pass'], $data['admin_pass'])) {
        $_SESSION['admin_id'] = $data['admin_id'];
        header("Location: index.php?admin");
        exit(-1);
    } else {
        $error = true;
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>

    <title>OpenVPN-Admin</title>

    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css"/>
    <link rel="stylesheet" href="css/bootstrap-editable.css" type="text/css"/>
    <link rel="stylesheet" href="css/bootstrap-table.min.css" type="text/css"/>
    <link rel="stylesheet" href="css/bootstrap-datepicker3.css" type="text/css"/>
    <link rel="stylesheet" href="css/index.css" type="text/css"/>

    <link rel="icon" type="image/png" href="img/icon.png">
</head>
<body class='container-fluid'>
<?php

// --------------- INSTALLATION ---------------
if (isset($_GET['installation'])) {
    if (isInstalled($bdd) == true) {
        printError('OpenVPN-admin is already installed. Redirection.');
        header("refresh:3;url=index.php?admin");
        exit(-1);
    }

    // If the user sent the installation form
    if (isset($_POST['admin_username'])) {
        $admin_username = $_POST['admin_username'];
        $admin_pass = $_POST['admin_pass'];
        $admin_repeat_pass = $_POST['repeat_admin_pass'];

        if ($admin_pass != $admin_repeat_pass) {
            printError('The passwords do not correspond. Redirection.');
            header("refresh:3;url=index.php?installation");
            exit(-1);
        }

        // Create the initial tables
        $migrations = getMigrationSchemas();
        foreach ($migrations as $migration_value) {
            $sql_file = dirname(__FILE__) . "/../scripts/sql/schema-$migration_value.sql";
            try {
                $sql = file_get_contents($sql_file);
                $bdd->exec($sql);
            } catch (PDOException $e) {
                printError($e->getMessage());
                exit(1);
            }

            unlink($sql_file);

            // Update schema to the new value
            updateSchema($bdd, $migration_value);
        }

        // Generate the hash
        $hash_pass = hashPass($admin_pass);

        // Insert the new admin
        $req = $bdd->prepare('INSERT INTO admin (admin_id, admin_pass) VALUES (?, ?)');
        $req->execute(array($admin_username, $hash_pass));

        rmdir(dirname(__FILE__) . '/sql');
        printSuccess('Well done, OpenVPN-Admin is installed. Redirection.');
        header("refresh:3;url=index.php?admin");
    } // Print the installation form
    else {
        require(dirname(__FILE__) . '/../app/html/menu.php');
        require(dirname(__FILE__) . '/../app/html/form/installation.php');
    }

    exit(-1);
}

// --------------- CONFIGURATION ---------------
if (!isset($_GET['admin'])) {
    if (isset($error) && $error == true)
        printError('Login error');

    require(dirname(__FILE__) . '/../app/html/menu.php');
    require(dirname(__FILE__) . '/../app/html/form/configuration.php');
} // --------------- LOGIN ---------------
else if (!isset($_SESSION['admin_id'])) {
    if (isset($error) && $error == true)
        printError('Login error');

    require(dirname(__FILE__) . '/../app/html/menu.php');
    require(dirname(__FILE__) . '/../app/html/form/login.php');
} // --------------- GRIDS ---------------
else {
    ?>
    <nav class="navbar navbar-default">
        <div class="row col-md-12">
            <div class="col-md-6">
                <p class="navbar-text signed">Signed in as <?php echo $_SESSION['admin_id']; ?>            </p>
            </div>
            <div class="col-md-6">
                <a class="navbar-text navbar-right" href="index.php?logout" title="Logout">
                    <button class="btn btn-danger">Logout</button>
                </a>
                <a class="navbar-text navbar-right" href="index.php" title="Configuration">
                    <button class="btn btn-default">Configurations</button>
                </a>
            </div>
        </div>
    </nav>

    <?php
    require(dirname(__FILE__) . '/../app/html/grids.php');
}
?>

<script src="js/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>
<script src="js/bootstrap-table.min.js"></script>
<script src="js/bootstrap-datepicker.js"></script>
<script src="js/bootstrap-table-editable.min.js"></script>
<script src="js/bootstrap-editable.js"></script>
<script src="js/grids.js"></script>
</body>
</html>
