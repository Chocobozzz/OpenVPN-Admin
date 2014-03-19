<?php
    session_start();
    
    if(isset($_GET['deconnexion'])){
        session_destroy();
        header("Location: .");
    }
    
    // Tentative de connexion ?
    if(isset($_POST['id'], $_POST['pass'])){
        require(dirname(__FILE__) . '/include/connexion_bdd.php');
        
        $req = $bdd->prepare('SELECT * FROM admin WHERE admin_id = ? AND admin_pass = ?');
        $req->execute(array($_POST['id'], sha1($_POST['pass'])));
        
        if($data = $req->fetch()){
            $_SESSION['admin_id'] = $data['admin_id'];
            header("Location: .");
        }
        else {
            $connexion_erreur = true;
        }
    }
?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        
        <!--<link rel="stylesheet" href="css/slick.grid.css" type="text/css" />
        <link rel="stylesheet" href="css/slick-default-theme.css" type="text/css" />
        <link rel="stylesheet" href="css/jquery-ui-1.8.16.custom.css" type="text/css" />
        <link rel="stylesheet" href="css/dropkick.css" type="text/css" />
        <link rel="stylesheet" href="css/enhancementpager.css" type="text/css" />
        <link rel="stylesheet" href="css/index.css" type="text/css"/>-->
        
        <link rel="stylesheet" href="css/min.css" type="text/css"/>
    </head>
    <body>
        <?php
            // Si pas connecté on affiche le formulaire
            if(!isset($_SESSION['admin_id'])){
                if($connexion_erreur)
                    echo "<strong style='color: red'>Erreur connexion</strong>";
        ?>
                <div id="bloc_connexion">
                    <form id="form_connexion" method="POST">
                        <label for="id">Pseudo :</label>
                        <input type="text" id="id" name="id" />
                        
                        <br /><br />
                        
                        <label for="pass">Mot de passe :</label>
                        <input type="password" id="pass" name="pass" />
                        
                        <br /><br />
                        
                        <input id="connexion" name="connexion" type="submit" value="Connexion" />
                    </form>
                </div>
        <?php
            }
            // Sinon on y met le javascript et les grilles
            else{
        ?>
                <div id="presentation_administrateur">
                    Administrateur : <?php echo $_SESSION['admin_id']; ?> / <a href="index.php?deconnexion" title="Se déconnecter ?">Déconnexion ?</a>
                </div>
                
                <div>
                    <div class="grid-header">
                      <label>Users</label>
                    </div>
                    <div class="grid" id="grid_user"></div>
                </div>
                
                <div>
                    <div class="grid-header">
                      <label>Logs</label>
                    </div>
                    <div class="grid" id="grid_log"></div>
                    <div id="pagination" class="slick-enhancement-pager"></div>
                </div>
                
                <div>
                    <div class="grid-header">
                      <label>Admin</label>
                    </div>
                    <div class="grid" id="grid_admin"></div>
                </div>
                
               
                <!--<script src="js/jquery-1.7.min.js"></script>
                <script src="js/jquery-ui-1.8.16.custom.min.js"></script>
                <script src="js/jquery.event.drag-2.2.js"></script>
                <script src="js/slick.core.js"></script>
                
                
                <script src="js/slick.formatters.js"></script>
                <script src="js/slick.editors.js"></script>
                <script src="js/slick.grid.js"></script>
                
                <script type="text/javascript" src="js/jquery.json-2.3.min.js"></script>
                <script type="text/javascript" src="js/jquery.dropkick-1.0.0.js" charset="utf-8"></script>
                <script src="js/slick.enhancementpager.js"></script>
                
                
                <script src="js/sha1-min.js"></script>
                <script src="js/index.js"></script>-->
                
                <script src="js/min.js"></script>
                
        <?php
            }
        ?>
    </body>
</html>
