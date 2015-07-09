<?php
  session_start();
  
  if(!isset($_SESSION['admin_id']))
    exit -1;

  require(dirname(__FILE__) . '/connect.php');
  require(dirname(__FILE__) . '/functions.php');
  
  
  // ---------------- SELECT ----------------
  if(isset($_POST['select'])){
      
    // Select the users
    if($_POST['select'] == "user"){
      $req = $bdd->prepare('SELECT * FROM user');
      $req->execute();
      
      if($data = $req->fetch()) {               
        do {                   
          $list[] = array("user_id" => $data['user_id'],
                          "user_pass" => $data['user_pass'],
                          "user_mail" => $data['user_mail'],
                          "user_phone" => $data['user_phone'],
                          "user_online" => $data['user_online'],
                          "user_enable" => $data['user_enable'],
                          "user_start_date" => dateFromSql($data['user_start_date']),
                          "user_end_date" => dateFromSql($data['user_end_date']));
        } while($data = $req->fetch());                      
        
        echo json_encode($list);           
      }
      // If it is an empty answer, we need to encore an empty json object
      else{
        $list = array();
        echo json_encode($list);   
      }
    }
    
    // Select the logs
    else if($_POST['select'] == "log"){
      // Creation of the LIMIT for build different pages
      if(isset($_POST['pageIndex'], $_POST['pageSize'])) {
        $actual_page = ($_POST['pageIndex']-1) * $_POST['pageSize'];
        $max_page = $_POST['pageSize'];
        $page = "LIMIT $actual_page, $max_page";
      }
      else {
        $page = "";
      }
      
      // Select the logs
      $string_requete = "SELECT *, (SELECT COUNT(*) FROM log) AS nb FROM log ORDER BY log_id DESC $page";
      $req = $bdd->prepare($string_requete);
      $req->execute();
      
      $list = array();
      
      $data = $req->fetch();
      
      if($data) {
        $nb = $data['nb'];
                    
        do {
          // Better in Kb or Mb
          $received = ($data['log_received'] > 100000) ? $data['log_received']/100000 . " Mo" : $data['log_received']/100 . " Ko";
          $sent = ($data['log_send'] > 100000) ? $data['log_send']/100000 . " Mo" : $data['log_send']/100 . " Ko";
          $start_time_array = explode(' ', $data['log_start_time']);
          $start_time = dateFromSql($start_time_array[0]) . ' ' . $start_time_array[1];
          $end_time_array = explode(' ', $data['log_end_time']);
          $end_time = dateFromSql($end_time_array[0]) . ' ' . $end_time_array[1];
          
          // We add to the array the new line of logs
          array_push($list, array(
                                  "log_id" => $data['log_id'],
                                  "user_id" => $data['user_id'],
                                  "log_trusted_ip" => $data['log_trusted_ip'],
                                  "log_trusted_port" => $data['log_trusted_port'],
                                  "log_remote_ip" => $data['log_remote_ip'],
                                  "log_remote_port" => $data['log_remote_port'],
                                  "log_start_time" => $start_time,
                                  "log_end_time" => $end_time,
                                  "log_received" => $received,
                                  "log_send" => $sent));
          
          
        } while ($data = $req->fetch());
      }
      else {
        $nb = 0;
      }
      
      // We finally print the result
      $result = array('Total' => $nb, 'Rows' => json_encode($list)); 
      
      echo json_encode($result);
    }
    
    // Select the admins
    else if($_POST['select'] == "admin"){
      $req = $bdd->prepare('SELECT * FROM admin');
      $req->execute();
      
      if($data = $req->fetch()) {               
        do{    
          $list[] = array(
                          "admin_id" => $data['admin_id'],
                          "admin_pass" => $data['admin_pass']
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
 
  // ---------------- ADD USER ----------------
  else if(isset($_POST['add_user'])){
    // Put some default values
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
    
    $res = array("user_id" => $id,
      "user_pass" => $pass,
      "user_mail" => $mail ,
      "user_phone" => $phone,
      "user_online" => $online,
      "user_enable" => $enable,
      "user_start_date" => dateFromSql($start),
      "user_end_date" => dateFromSql($end)
    );
    
    echo json_encode($res);
  }
  
  // ---------------- UPDATE USER ----------------
  else if(isset($_POST['set_user'])){
    $valid = array("user_id", "user_pass", "user_mail", "user_phone", "user_enable", "user_start_date", "user_end_date");
    $set_field = $set_value = array();
    
    // Only update what was modified
    foreach($_POST as $key => $value){
      if(in_array($key, $valid)){
        array_push($set_field, $key . "=?");
        
        if($key == "user_pass")
          if($value == "")
            array_push($set_value, $value);
          else
            array_push($set_value, hashPass($value));
        else if($key == "user_start_date" || $key == "user_end_date")
          array_push($set_value, dateToSql($value));
        else
          array_push($set_value, $value);
      }
    }
    // Build the request
    array_push($set_value, $_POST['set_user']);
    
    $req_string = 'UPDATE user SET ' . implode(',', $set_field) . ' WHERE user_id = ?';
    $req = $bdd->prepare($req_string);
    $req->execute($set_value);
  }
  
  // ---------------- REMOVE USER ----------------
  else if(isset($_POST['del_user_id'])){
    $req = $bdd->prepare('DELETE FROM user WHERE user_id = ?');
    $req->execute(array($_POST['del_user_id']));
  }
  
  // ---------------- ADD ADMIN ----------------
  else if(isset($_POST['add_admin'])){
    $req = $bdd->prepare('INSERT INTO admin(admin_id, admin_pass) VALUES (?, ?)');
    $req->execute(array($_POST['admin_id'], ""));
  }
  
  // ---------------- UPDATE ADMIN ----------------
  else if(isset($_POST['set_admin'])){
    $mdp = $_POST['admin_pass'] ? hashPass($_POST['admin_pass']) : "";
    
    $req = $bdd->prepare('UPDATE admin SET admin_id = ?, admin_pass = ? WHERE admin_id = ?');
    $req->execute(array($_POST['admin_id'], $mdp, $_POST['set_admin']));
  }
  
  // ---------------- REMOVE ADMIN ----------------
  else if(isset($_POST['del_admin_id'])){
    $req = $bdd->prepare('DELETE FROM admin WHERE admin_id = ?');
    $req->execute(array($_POST['del_admin_id']));
  }

?>
