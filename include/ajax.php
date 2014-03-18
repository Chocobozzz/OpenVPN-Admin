<?php
    session_start();
    
    if(!isset($_SESSION['admin_id']))
        exit -1;

    require(basename(__FILE__) . 'connexion_bdd.php');
    
    function datetosql($date) {
        return implode('-', array_reverse(explode('/', $date)));
    }
    
    function datefromsql($date) {
        return implode('/', array_reverse(explode('-', $date)));
    }
    
    // Selection des données
    if(isset($_POST['select'])){
        
        // User pouvant se connecter au VPN
        if($_POST['select'] == "user"){
            $req = $bdd->prepare('SELECT * FROM user');
            $req->execute();
            
            if($data = $req->fetch()) {               
                do{                   
                    $list[] = array("user_id" => $data['user_id'],
                                    "user_pass" => $data['user_pass'],
                                    "user_mail" => $data['user_mail'],
                                    "user_phone" => $data['user_phone'],
                                    "user_online" => $data['user_online'],
                                    "user_enable" => $data['user_enable'],
                                    "user_start_date" => datefromsql($data['user_start_date']),
                                    "user_end_date" => datefromsql($data['user_end_date']));
                } while($data = $req->fetch());                      
                
                echo json_encode($list);           
            }
            else{
                $list = array();
                echo json_encode($list);   
            }
        }
        // Log du VPN
        else if($_POST['select'] == "log"){
            // Création du LIMIT de la requête SQL en fonction de la page
            if(isset($_POST['pageIndex'], $_POST['pageSize'])) {
                $page_actuelle = ($_POST['pageIndex']-1) * $_POST['pageSize'];
                $page_max = $_POST['pageSize'];
                $page = " LIMIT " . $page_actuelle . ", " . $page_max;
            }
            else {
                $page = "";
            }
            
            // Sélection des logs
            $string_requete = 'SELECT * FROM log ORDER BY log_id DESC' . $page;
            $req = $bdd->prepare($string_requete);
            $req->execute();
            
            $list = array();
                        
            while($data = $req->fetch()) {
                // C'est mieux exprimé en Mo ou Ko
                $received = ($data['log_received'] > 100000) ? $data['log_received']/100000 . " Mo" : $data['log_received']/100 . " Ko";
                $sent = ($data['log_send'] > 100000) ? $data['log_send']/100000 . " Mo" : $data['log_send']/100 . " Ko";
                $start_time_array = explode(' ', $data['log_start_time']);
                $start_time = datefromsql($start_time_array[0]) . ' ' . $start_time_array[1];
                $end_time_array = explode(' ', $data['log_end_time']);
                $end_time = datefromsql($end_time_array[0]) . ' ' . $end_time_array[1];
                
                // On ajoute à notre tableau la nouvelle ligne de log
                array_push($list, array("log_id" => $data['log_id'],
                                "user_id" => $data['user_id'],
                                "log_trusted_ip" => $data['log_trusted_ip'],
                                "log_trusted_port" => $data['log_trusted_port'],
                                "log_remote_ip" => $data['log_remote_ip'],
                                "log_remote_port" => $data['log_remote_port'],
                                "log_start_time" => $start_time,
                                "log_end_time" => $end_time,
                                "log_received" => $received,
                                "log_send" => $sent));
            }
            
            // Récupération du nombre lignes de log
            $req_nb = $bdd->prepare('SELECT COUNT(*) AS nb FROM log');
            $req_nb->execute();
            $data_nb = $req_nb->fetch()['nb'];
            
            // On affiche la réponse JSON
            $result = array('Total' => $data_nb, 'Rows' => json_encode($list)); 
            
            echo json_encode($result);
        }
        // Affichage des personnes pouvant se connecter à l'interface d'administration
        else if($_POST['select'] == "admin"){
            $req = $bdd->prepare('SELECT * FROM admin');
            $req->execute();
            
            if($data = $req->fetch()) {               
                do{    
                    $list[] = array("admin_id" => $data['admin_id'],
                                    "admin_pass" => $data['admin_pass'],
                                    );
                } while($data = $req->fetch());                      
                
                echo json_encode($list);           
            }
            else{
                $list = array();
                echo json_encode($list);   
            }
        }
    }
    // Ajout d'un utilisateur du VPN
    else if(isset($_POST['add_user'])){
        $id = $_POST['user_id'];
        $pass = "";
        $mail = "";
        $phone = "";
        $online = 0;
        $enable = 1;
        $start = "0000-00-00";
        $end = "0000-00-00";
        
        $req = $bdd->prepare('INSERT INTO user (user_id, user_pass, user_mail, user_phone, user_online, user_enable, user_start_date, user_end_date)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
        $req->execute(array($id, $pass, $mail, $phone, $online, $enable, $start, $end));
    }
    // Modification d'un utilisateur du VPN
    else if(isset($_POST['set_user'])){
        $valid = array("user_id", "user_pass", "user_mail", "user_phone", "user_enable", "user_start_date", "user_end_date");
        $set_field = $set_value = array();
        
        // Algo pour mettre à jour seulement ce qui a été modifié
        foreach($_POST as $key => $value){
            if(in_array($key, $valid)){
                array_push($set_field, $key . "=?");
                
                if($key == "user_pass")
                    if($value == "")
                        array_push($set_value, $value);
                    else
                        array_push($set_value, sha1($value));
                else if($key == "user_start_date" || $key == "user_end_date")
                    array_push($set_value, datetosql($value));
                else
                    array_push($set_value, $value);
            }
        }
        // Construction de la requête
        array_push($set_value, $_POST['set_user']);
        
        $req_string = 'UPDATE user SET ' . implode(',', $set_field) . ' WHERE user_id = ?';
        $req = $bdd->prepare($req_string);
        $req->execute($set_value);
    }
    // Suppression d'un utilisateur du VPN
    else if(isset($_POST['del_user_id'])){
        $req = $bdd->prepare('DELETE FROM user WHERE user_id = ?');
        $req->execute(array($_POST['del_user_id']));
    }
    // Ajout d'un admin
    else if(isset($_POST['add_admin'])){
        $req = $bdd->prepare('INSERT INTO admin(admin_id, admin_pass) VALUES (?, ?)');
        $req->execute(array($_POST['admin_id'], ""));
    }
    // Modification d'un admin
    else if(isset($_POST['set_admin'])){
        $mdp = $_POST['admin_pass'] ? sha1($_POST['admin_pass']) : "";
        
        $req = $bdd->prepare('UPDATE admin SET admin_id = ?, admin_pass = ? WHERE admin_id = ?');
        $req->execute(array($_POST['admin_id'], $mdp, $_POST['set_admin']));
    }
    // Suppression d'un admin
    else if(isset($_POST['del_admin_id'])){
        $req = $bdd->prepare('DELETE FROM admin WHERE admin_id = ?');
        $req->execute(array($_POST['del_admin_id']));
    }
 
?>
