$(function () {
  "use strict";

  // ------------------------- GENERIC STUFF ------------------------------
  window.printStatus = function(msg, alert_type='warning', bootstrap_icon='') {
     $('#message-stage').empty()
         .append(
            $(document.createElement('div'))
            .addClass('alert alert-'+alert_type)
            .html(bootstrap_icon?'<i class="stauts-icon glyphicon glyphicon-'+bootstrap_icon+'"></i>':'')
            .append(msg)
            .hide().fadeIn().delay(2000).fadeOut()
         );
  }

  // ------------------------- GLOBAL definitions -------------------------
  var gridsUrl = 'include/grids.php';

  function deleteFormatter() {
    return "<span class='glyphicon glyphicon-remove action'></span";
  }

  function refreshTable($table) {
    $table.bootstrapTable('refresh');
  }

  function onAjaxError (xhr, textStatus, error) {
    console.error(error);
    alert('Error: ' + textStatus);
  }

   function checkFormatter(value, row, index) {
      return '<input type="checkbox" '+(parseInt(value)===1?'checked':'')+' />';
   }

   function LEDIndicatorFormatter(value, row, index) {
      return '<div class="'+(parseInt(value)===1?'mini-led-green':'mini-led-red')+'"></div>';
   }

  // ------------------------- USERS definitions -------------------------
  var $userTable = $('#table-users');
  var $modalUserAdd = $('#modal-user-add');
  var $userAddSave = $modalUserAdd.find('#modal-user-add-save');

  function addUser(username, password) {
    $.ajax({
      url: gridsUrl,
      method: 'POST',
      data: {
        add_user: true,
        user_id: username,
        user_pass: password
      },
      success: function() {
        refreshTable($userTable);
      },
      error: onAjaxError
    });
  }

  function deleteUser(user_id) {
    $.ajax({
      url: gridsUrl,
      data: {
        del_user: true,
        del_user_id: user_id
      },
      method: 'POST',
      success: function() {
        refreshTable($userTable);
      },
      error: onAjaxError
    });
  }

  function genericSetField(field, new_value, pk) {
    $.ajax({
      url: gridsUrl,
      data: {
        set_user: true,
        name: field,
        value: new_value,
        pk : pk
      },
      method: 'POST',
      success: function() {
        refreshTable($userTable);
      },
      error: onAjaxError
    });
  }

  var userEditable = {
    url: gridsUrl,
    params: function (params) {
      params.set_user = true;

      return params;
    },
    success: function () {
      refreshTable($userTable);
    }
  }

  function updateConfig(config_file, config_content) {
    $.ajax({
      url: gridsUrl,
      data: {
        update_config : true,
        config_file: config_file,
        config_content: config_content
      },
      success : function(res){
         printStatus(
            res.config_success?'Config Successfully updated!':'An error occured while trying to save the updated config.',
            res.config_success?'success':'danger',
            res.config_success?'ok':'warning-sign'
         );
      },
      dataType : 'json',
      method: 'POST',
      error: onAjaxError
    });
  }

  // ES 2015 so be prudent
  if (typeof Object.assign == 'function') {
    var userDateEditable = Object.assign({ type: 'date', placement: 'bottom' }, userEditable);
  } else {
    console.warn('Your browser does not support Object.assign. You will not be able to modify the date inputs.');
  }


  // ------------------------- ADMIN definitions -------------------------
  var $adminTable = $('#table-admins');
  var $modalAdminAdd = $('#modal-admin-add');
  var $adminAddSave = $modalAdminAdd.find('#modal-admin-add-save');

  function addAdmin(username, password) {
    $.ajax({
      url: gridsUrl,
      method: 'POST',
      data: {
        add_admin: true,
        admin_id: username,
        admin_pass: password
      },
      success: function() {
        refreshTable($adminTable);
      },
      error: onAjaxError
    });
  }

  function deleteAdmin(admin_id) {
    $.ajax({
      url: gridsUrl,
      data: {
        del_admin: true,
        del_admin_id: admin_id
      },
      method: 'POST',
      success: function() {
        refreshTable($adminTable);
      },
      error: onAjaxError
    });
  }

  var adminEditable = {
    url: gridsUrl,
    params: function (params) {
      params.set_admin = true;

      return params;
    },
    success: function () {
      refreshTable($adminTable);
    }
  }

  // ------------------------- ADMIN definitions -------------------------
  var $logTable = $('#table-logs');


  // -------------------- USERS --------------------

  // Bootstrap table definition
  $userTable.bootstrapTable({
    url: gridsUrl,
    sortable: false,
    checkboxHeader: false,
    queryParams: function (params) {
      params.select = 'user';
      return params;
    },
    // Primary key
    idField: 'user_id',
    columns: [
      { title: "ID", field: "user_id", editable: userEditable },
      { title: "Pass", field: "user_pass", editable: userEditable },
      { title: "Mail", field: "user_mail", editable: userEditable },
      { title: "Phone", field: "user_phone", editable: userEditable },
      {
         title: "Online",
         field: "user_online",
         formatter : LEDIndicatorFormatter
      },
      {
         title: "Enabled",
         field: "user_enable",
         formatter : checkFormatter,
         events: {
            'click input': function (e, value, row) {
              genericSetField('user_enable', value === '1' ? '0': '1', row.user_id);
            }
         }
      },
      { title: "Start Date", field: "user_start_date", editable: userDateEditable },
      { title: "End Date", field: "user_end_date", editable: userDateEditable },
      {
        title: 'Delete',
        field: "user_del",
        formatter: deleteFormatter,
        events: {
          'click .glyphicon': function (e, value, row) {
            if (confirm('Are you sure you want to delete this user?')) {
              deleteUser(row.user_id);
            }
          }
        }
      }
    ]
  });

  // When we want to add a user
  $userAddSave.on('click', function () {
    var $usernameInput = $modalUserAdd.find('input[name=username]');
    var $passwordInput = $modalUserAdd.find('input[name=password]');
    addUser($usernameInput.val(), $passwordInput.val());
    $modalUserAdd.modal('hide');
  });


  // -------------------- ADMINS --------------------

  // Bootstrap table definition
  $adminTable.bootstrapTable({
    url: gridsUrl,
    sortable: false,
    queryParams: function (params) {
      params.select = 'admin';
      return params;
    },
    // Primary key
    idField: 'admin_id',
    columns: [
      { title: "ID", field: "admin_id", editable: adminEditable },
      { title: "Pass", field: "admin_pass", editable: adminEditable },
      {
        title: 'Delete',
        field: "admin_del",
        formatter: deleteFormatter,
        events: {
          'click .glyphicon': function (e, value, row) {
            if (confirm('Are you sure you want to delete this admin?')) {
              deleteAdmin(row.admin_id);
            }
          }
        }
      }
    ]
  });

  // When we want to add a user
  $adminAddSave.on('click', function () {
    var $usernameInput = $modalAdminAdd.find('input[name=username]');
    var $passwordInput = $modalAdminAdd.find('input[name=password]');
    addAdmin($usernameInput.val(), $passwordInput.val());
    $modalAdminAdd.modal('hide');
  });

  // -------------------- LOGS --------------------

  // Bootstrap table definition
  $logTable.bootstrapTable({
    url: gridsUrl,
    sortable: false,
    sidePagination: 'server',
    pagination: true,
    queryParams: function (params) {
      params.select = 'log';
      return params;
    },
    columns: [
      { title: "Log ID", field: "log_id" },
      { title: "User ID", field: "user_id", filterControl : 'select' },
      { title: "Trusted IP", field: "log_trusted_ip", filterControl : 'select' },
      { title: "Trusted Port", field: "log_trusted_port", filterControl : 'select' },
      { title: "Remote IP", field: "log_remote_ip", filterControl : 'select' },
      { title: "Remote Port", field: "log_remote_port", filterControl : 'select' },
      { title: "Start Time", field: "log_start_time" },
      { title: "End Time", field: "log_end_time" },
      { title: "Receveid", field: "log_received" },
      { title: "Sent", field: "log_send" }
    ]
  });

  // watch the config textareas for changes an persist them if a change was made
  $('textarea').keyup(function(){
     $('#save-config-btn').removeClass('saved-success hidden').addClass('get-attention');
  }).change(function(){
      updateConfig($(this).data('config-file'), $(this).val());
      $('#save-config-btn').removeClass('get-attention').addClass('saved-success');
  });

}); // doc ready end

// -------------------- HACKS --------------------

// Autofocus for bootstrap modals
// Thx http://stackoverflow.com/questions/14940423/autofocus-input-in-twitter-bootstrap-modal/33323836#33323836

$(document).on('shown.bs.modal', '.modal', function() {
  $(this).find('[autofocus]').focus();
});
