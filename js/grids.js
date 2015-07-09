$(function () {
  "use strict";

  // -------------------- USERS --------------------
  $.ajax({
    type: "POST",
    url: "include/grids.php",
    dataType: 'json',
    data: "select=user",
    success: function (json) {
      // Button to format a cell and remove an user
      function buttonFormatter(row, cell, value, columnDef, dataContext) {
        var button = "<span class='glyphicon glyphicon-remove delete del_user' data-row='" + row + "' id='" + dataContext.user_id + "'></span>";
        return button;
      }

      var i;
      var columns = [
        { id: "user_id", name: "ID", field: "user_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "user_pass", name: "Pass", field: "user_pass", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "user_mail", name: "Mail", field: "user_mail", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "user_phone", name: "Phone", field: "user_phone", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "user_online", name: "Online", field: "user_online", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "user_enable", name: "Enabled", field: "user_enable", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "user_start_date", name: "Start Date", field: "user_start_date", width: 120, cssClass: "cell-title", editor: Slick.Editors.Date },
        { id: "user_end_date", name: "End Date", field: "user_end_date", width: 120, cssClass: "cell-title", editor: Slick.Editors.Date },
        { id: "user_del", name: 'Delete', field: "user_del", width: 250, formatter: buttonFormatter }
      ];

      // Grid options
      var options = {
        editable: true,
        enableAddRow: true,
        enableCellNavigation: true,
        asyncEditorLoading: false,
        autoEdit: false,
        autoHeight: true
      };
      
      var data = [];

      // Save the old user_id when the admin update an user
      var save = null;

      var grid = null;
      
      // Action when we want to remove an user
      $('#user-grid').on('click', '.del_user', function () {

        // Remove from the database
        var me = $(this), id = me.attr('id');
        var data = grid.getData();

        $.ajax({
          type: "POST",
          url: "include/grids.php",
          dataType: "json",
          data: { del_user_id: id },
          success: function() {
            // Remove the line
            data.splice(me.attr('data-row'), 1);
            grid.setData(data);
            grid.render();
          },
          error: function () {
            alert("Error: cannot update the database.");
          }
        });        
      });


      for (i = 0; i < json.length; i += 1) {
        data[i] = {
          user_id: json[i].user_id,
          user_pass: json[i].user_pass,
          user_mail: json[i].user_mail,
          user_phone: json[i].user_phone,
          user_online: json[i].user_online,
          user_enable: json[i].user_enable,
          user_start_date: json[i].user_start_date,
          user_end_date: json[i].user_end_date
        };
      }

      // Grid of the users
      grid = new Slick.Grid($("#grid_user"), data, columns, options);

      $("#grid_user").on('click', function () {
        var $active = grid.getActiveCell();

        if ($active && $active.cell === 0) {
          save = $(grid.getActiveCellNode()).html();
        } else {
          save = null;
        }
      });

      // When we want to modify an user
      grid.onCellChange.subscribe(function (e, args) {
        var item = args.item;

        if (save)
          item.set_user = save;
        else
          item.set_user = item.user_id;

        // Remove in the database
        $.ajax({
          type: "POST",
          url: "include/grids.php",
          dataType: "json",
          data: item,
          success: function () {
            // If we edited the password, hash it
            if(args.cell === 1) {
              grid.invalidateRow(args.row);
              data[args.row][grid.getColumns()[args.cell].field] = sha1(data[args.row][grid.getColumns()[args.cell].field]);
              grid.render();  
            }
          },
          error: function () {
            alert("Error : cannot update the database.");
          }
        });

        delete item.set_user;
      });

      // Add a new user
      grid.onAddNewRow.subscribe(function (e, args) {
        var item = args.item;

        // We only can add a new user if we specify his id
        if (!item.user_id)
          return;
          
        item.add_user = true;

        // Update the database
        $.ajax({
          type: "POST",
          url: "include/grids.php",
          dataType: "json",
          data: item,
          success: function(res) {
            // Update the grid
            grid.invalidateRow(data.length);
            data.push(res);
            grid.updateRowCount();
            grid.render();
          },
          error: function () {
            alert("Error : cannot update the database.");
          }
        });
        
        delete item.add_user;
      });

      grid.autosizeColumns();
    },
    error: function () {
      alert('Error : cannot get the data.');
    }
  });


  // -------------------- ADMINISTRATORS --------------------
  $.ajax({
    type: "POST",
    url: "include/grids.php",
    dataType: 'json',
    data: "select=admin",
    success: function (json) {
      // Create the button to remove an administrator
      function buttonFormatter(row, cell, value, columnDef, dataContext) {  
        var button = "<span class='glyphicon glyphicon-remove delete del_admin' data-row='" + row + "' id='" + dataContext.admin_id + "'></span>";
        return button;
      }

      var i;

      // Header
      var columns = [
        { id: "admin_id", name: "Admin ID", field: "admin_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "admin_pass", name: "Admin Pass", field: "admin_pass", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
        { id: "admin_del", name: 'Delete', field: "admin_del", width: 250, formatter: buttonFormatter }
      ];

      // Grid options
      var  options = {
        editable: true,
        enableAddRow: true,
        enableCellNavigation: true,
        asyncEditorLoading: false,
        autoEdit: false,
        autoHeight: true
      };

      var data = [];
      var grid = null;

      // Save the old admin id when we update one
      var save = null;

      // When we want to remove an administrator
      $('#admin-grid').on('click', '.del_admin', function () {
        var me = $(this);
        var id = me.attr('id');
        var data = grid.getData();
        
        // Update the database
        $.ajax({
          type: "POST",
          url: "include/grids.php",
          dataType: "json",
          data: { del_admin_id: id },
          success: function() {
            // Update the grid
            data.splice(me.attr('data-row'), 1);
            grid.setData(data);
            grid.render();
          },
          error: function () {
            alert("Error : cannot update the database.");
          }
        });
      });


      for (i = 0; i < json.length; i += 1) {
        data[i] = {
          admin_id: json[i].admin_id,
          admin_pass: json[i].admin_pass
        };
      }

      grid = new Slick.Grid($("#grid_admin"), data, columns, options);

      $("#grid_admin").on('click', function () {
        var $active = grid.getActiveCell();

        if ($active !== undefined && $active.cell === 0)
          save = $(grid.getActiveCellNode()).html();
        else
          save = null;
      });

      // When we update the administrator
      grid.onCellChange.subscribe(function (e, args) {
        var item = args.item;

        // We save the old admin id
        if (save)
          item.set_admin = save;
        else
          item.set_admin = item.admin_id;

        // Update the database
        $.ajax({
          type: "POST",
          url: "include/grids.php",
          dataType: "json",
          data: item,
          success: function() {
            // Hash the password
            if(args.cell === 1) {
              grid.invalidateRow(args.row);
              data[args.row][grid.getColumns()[args.cell].field] = sha1(data[args.row][grid.getColumns()[args.cell].field]);
              grid.render();  
            }
          },
          error: function () {
            alert("Error : cannot update the database");
          }
        });

        delete item.set_admin;
      });

      // When we want to add a new administrator
      grid.onAddNewRow.subscribe(function (e, args) {
        var item = args.item;

        // We only add an administrator if we specify the ID
        if (!item.admin_id)
          return;

        item.add_admin = true;

        // Update the database
        $.ajax({
          type: "POST",
          url: "include/grids.php",
          dataType: "json",
          data: item,
          success: function() {
            // Update the grid
            grid.invalidateRow(data.length);
            data.push(item);
            grid.updateRowCount();
            grid.render();
          },
          error: function () {
            alert("Error : cannot update the database.");
          }
        });

        delete item.add_admin;

        
      });

      grid.autosizeColumns();
    },
    error: function () {
      alert('Erreur dans la récupération des données...');
    }
  });
  
  
  
  // -------------------- LOGS --------------------
  var i;

  // Headers
  var columns = [
    { id: "log_id", name: "Log ID", field: "log_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "user_id", name: "User ID", field: "user_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_trusted_ip", name: "Trusted IP", field: "log_trusted_ip", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_trusted_port", name: "Trusted Port", field: "log_trusted_port", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_remote_ip", name: "Remote IP", field: "log_remote_ip", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_remote_port", name: "Remote Port", field: "log_remote_port", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_start_time", name: "Start Time", field: "log_start_time", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_end_time", name: "End Time", field: "log_end_time", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_received", name: "Receveid", field: "log_received", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text },
    { id: "log_send", name: "Sent", field: "log_send", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text }
  ];

  // Grid options
  var options = {
    editable: false,
    enableAddRow: false,
    enableCellNavigation: true,
    asyncEditorLoading: false,
    autoEdit: false,
    autoHeight: true
  };
  
  var data = [];
  
  // Creation of the grid
  var grid = new Slick.Grid($("#grid_log"), data, columns, options);
  
  var pager = new Slick.Controls.EnhancementPager({
    container: $("#pager"),
    remoteUrl: "include/grids.php",
    params: { select: "log" },
    datagrid: grid,
    pagerType: ""
  });

  grid.autosizeColumns();
  
});
