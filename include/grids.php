<?php
  session_start();

  if(!isset($_SESSION['admin_id']))
    exit -1;

  require(dirname(__FILE__) . '/connect.php');
  require(dirname(__FILE__) . '/functions.php');


  // ---------------- SELECT ----------------
  if(isset($_GET['select'])){

    // Select the users
    if($_GET['select'] == "user"){
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
                          "user_start_date" => $data['user_start_date'],
                          "user_end_date" => $data['user_end_date']);
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
    else if($_GET['select'] == "log" && isset($_GET['offset'], $_GET['limit'])){
      $offset = intval($_GET['offset']);
      $limit = intval($_GET['limit']);

      // Creation of the LIMIT for build different pages
      $page = "LIMIT $offset, $limit";

      // ... filtering by the bootstrap table plugin
      $filter = isset($_GET['filter']) ? json_decode($_GET['filter'],true) : []; // this is passed by the bootstrap table filter plugin (if a filter was chosen by the user): these are the concrete set filters with their value
      $where = !empty($filter)?'WHERE TRUE':'';
      $allowed_query_filters = ['user_id', 'log_trusted_ip','log_trusted_port','log_remote_ip','log_remote_port']; // these are valid filters that could be used (defined here for sql security reason)
      $query_filters_existing = [];
      foreach($filter as $unsanitized_filter_key => $unsanitized_filter_val) {
         if(in_array($unsanitized_filter_key, $allowed_query_filters)) { // if this condition does not match: ignore it, because this parameter should not be passed
            // if $unsanitized_filter_key is in array $allowed_query_filters its a valid key and can not be harmful, so it can be considered sanitized
            $where .= " AND $unsanitized_filter_key = ?";
            $query_filters_existing[] = $unsanitized_filter_key;
         }
      }

      // Select the logs
      $req_string = "SELECT *, (SELECT COUNT(*) FROM log $where) AS nb FROM log $where ORDER BY log_id DESC $page";
      $req = $bdd->prepare($req_string);

      // dynamically bind the params
      foreach(array_merge($query_filters_existing,$query_filters_existing) as $i => $query_filter) // array_merge -> duplicated the array contents; this is needed because our where clause is bound two times (in subquery + the outer query)
         $req->bindValue($i+1, $filter[$query_filter]);

      $req->execute();

      $list = array();

      $data = $req->fetch();

      if($data) {
        $nb = $data['nb'];

        do {
          // Better in Kb or Mb
          $received = ($data['log_received'] > 1000000) ? $data['log_received']/1000000 . " Mo" : $data['log_received']/1000 . " Ko";
          $sent = ($data['log_send'] > 1000000) ? $data['log_send']/1000000 . " Mo" : $data['log_send']/1000 . " Ko";

          // We add to the array the new line of logs
          array_push($list, array(
                                  "log_id" => $data['log_id'],
                                  "user_id" => $data['user_id'],
                                  "log_trusted_ip" => $data['log_trusted_ip'],
                                  "log_trusted_port" => $data['log_trusted_port'],
                                  "log_remote_ip" => $data['log_remote_ip'],
                                  "log_remote_port" => $data['log_remote_port'],
                                  "log_start_time" => $data['log_start_time'],
                                  "log_end_time" => $data['log_end_time'],
                                  "log_received" => $received,
                                  "log_send" => $sent));

        } while ($data = $req->fetch());
      }
      else {
        $nb = 0;
      }

      // We finally print the result
      $result = array('total' => intval($nb), 'rows' => $list);

      echo json_encode($result);
    }

    // Select the admins
    else if($_GET['select'] == "admin"){
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
  else if(isset($_POST['add_user'], $_POST['user_id'], $_POST['user_pass'])){
    // Put some default values
    $id = $_POST['user_id'];
    $pass = hashPass($_POST['user_pass']);
    $mail = "";
    $phone = "";
    $online = 0;
    $enable = 1;
    $start = NULL;
    $end = NULL;

    $req = $bdd->prepare('INSERT INTO user (user_id, user_pass, user_mail, user_phone, user_online, user_enable, user_start_date, user_end_date)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
    $req->execute(array($id, $pass, $mail, $phone, $online, $enable, $start, $end));

    $res = array("user_id" => $id,
      "user_pass" => $pass,
      "user_mail" => $mail ,
      "user_phone" => $phone,
      "user_online" => $online,
      "user_enable" => $enable,
      "user_start_date" => $start,
      "user_end_date" => $end
    );

    echo json_encode($res);
  }

  // ---------------- UPDATE USER ----------------
  else if(isset($_POST['set_user'])){
    $valid = array("user_id", "user_pass", "user_mail", "user_phone", "user_enable", "user_start_date", "user_end_date");

    $field = $_POST['name'];
    $value = $_POST['value'];
    $pk = $_POST['pk'];

    if (!isset($field) || !isset($pk) || !in_array($field, $valid)) {
      return;
    }

    if ($field === 'user_pass') {
      $value = hashPass($value);
    }
    else if (($field === 'user_start_date' || $field === 'user_end_date') && $value === '') {
      $value = NULL;
    }

    // /!\ SQL injection: field was checked with in_array function
    $req_string = 'UPDATE user SET ' . $field . ' = ? WHERE user_id = ?';
    $req = $bdd->prepare($req_string);
    $req->execute(array($value, $pk));
  }

  // ---------------- REMOVE USER ----------------
  else if(isset($_POST['del_user'], $_POST['del_user_id'])){
    $req = $bdd->prepare('DELETE FROM user WHERE user_id = ?');
    $req->execute(array($_POST['del_user_id']));
  }

  // ---------------- ADD ADMIN ----------------
  else if(isset($_POST['add_admin'], $_POST['admin_id'], $_POST['admin_pass'])){
    $req = $bdd->prepare('INSERT INTO admin(admin_id, admin_pass) VALUES (?, ?)');
    $req->execute(array($_POST['admin_id'], hashPass($_POST['admin_pass'])));
  }

  // ---------------- UPDATE ADMIN ----------------
  else if(isset($_POST['set_admin'])){
    $valid = array("admin_id", "admin_pass");

    $field = $_POST['name'];
    $value = $_POST['value'];
    $pk = $_POST['pk'];

    if (!isset($field) || !isset($pk) || !in_array($field, $valid)) {
      return;
    }

    if ($field === 'admin_pass') {
      $value = hashPass($value);
    }

    $req_string = 'UPDATE admin SET ' . $field . ' = ? WHERE admin_id = ?';
    $req = $bdd->prepare($req_string);
    $req->execute(array($value, $pk));
  }

  // ---------------- REMOVE ADMIN ----------------
  else if(isset($_POST['del_admin'], $_POST['del_admin_id'])){
    $req = $bdd->prepare('DELETE FROM admin WHERE admin_id = ?');
    $req->execute(array($_POST['del_admin_id']));
  }

  // ---------------- UPDATE CONFIG ----------------
  else if(isset($_POST['update_config'])){

      $pathinfo = pathinfo($_POST['config_file']);

      $config_full_uri = $_POST['config_file']; // the complete path to the file, including the file (name) its self and the fully qualified path
      $config_full_path = $pathinfo['dirname']; // path to file (without filename its self)
      $config_name = basename($_POST['config_file']); // config file name only (without path)
      $config_parent_dir = basename($config_full_path); // name of the dir that contains the config file (without path)

      /*
       * create backup for history
       */
      if (!file_exists($dir="../$config_full_path/history"))
         mkdir($dir, 0777, true);
      $ts = time();
      copy("../$config_full_uri", "../$config_full_path/history/${ts}_${config_name}");

      /*
       *  write config
       */
      $conf_success = file_put_contents('../'.$_POST['config_file'], $_POST['config_content']);

      echo json_encode([
        'debug' => [
            'config_file' => $_POST['config_file'],
            'config_content' => $_POST['config_content']
        ],
        'config_success' => $conf_success !== false,
      ]);
  }

?>
