$(function () {
  "use strict";

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
    queryParams: function (params) {
      params.select = 'user';
      return params;
    },
    // Primary key
    idField: 'memberID',
    columns: [
      { title: "ID", field: "memberID", editable: userEditable },
      { title: "Name", field: "username", editable: userEditable },
      { title: "Pass", field: "password", editable: userEditable },
      { title: "Mail", field: "email", editable: userEditable },
      { title: "Phone", field: "phone", editable: userEditable },
      { title: "Subscription", field: "subscription", editable: userEditable },
      { title: "Online", field: "online" },
      { title: "Enabled", field: "enable", editable: userEditable },
      { title: "Start Date", field: "startdate", editable: userDateEditable },
      { title: "End Date", field: "enddate", editable: userDateEditable },
      { title: "Active", field: "activate", editable: userDateEditable },
      { title: "ResetToken", field: "resetToken", editable: userDateEditable },
      { title: "ResetComplete", field: "resetComplete", editable: userDateEditable },
      {
        title: 'Delete',
        field: "user_del",
        formatter: deleteFormatter,
        events: {
          'click .glyphicon': function (e, value, row) {
            if (confirm('Are you sure you want to delete this user?')) {
              deleteUser(row.memberID);
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
      { title: "User ID", field: "user_id" },
      { title: "Trusted IP", field: "log_trusted_ip" },
      { title: "Trusted Port", field: "log_trusted_port" },
      { title: "Remote IP", field: "log_remote_ip" },
      { title: "Remote Port", field: "log_remote_port" },
      { title: "Start Time", field: "log_start_time" },
      { title: "End Time", field: "log_end_time" },
      { title: "Receveid", field: "log_received" },
      { title: "Sent", field: "log_send" }
    ]
  });
});

// -------------------- HACKS --------------------

// Autofocus for bootstrap modals
// Thx http://stackoverflow.com/questions/14940423/autofocus-input-in-twitter-bootstrap-modal/33323836#33323836

$(document).on('shown.bs.modal', '.modal', function() {
  $(this).find('[autofocus]').focus();
});
