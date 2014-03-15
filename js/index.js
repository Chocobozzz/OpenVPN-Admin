/*jslint browser: true*/
/*global $, Slick, grid, jQuery, alert*/

$(function () {
    "use strict";

    // Selection des users
    $.ajax({
        type: "POST",
        url: "ajax.php",
        dataType: 'json',
        data: "select=user",
        success: function (json) {
            // Bouton pour formater la cellule pour supprimer un user
            function buttonFormatter(row, cell, value, columnDef, dataContext) {
                var button = "<img src='images/drop.png' class='delete del_user' data-row='" + row + "' id='" + dataContext.user_id + "' />";
                return button;
            }

            var
                i,
                columns = [
                    {id: "user_id", name: "ID", field: "user_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "user_pass", name: "Pass", field: "user_pass", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "user_mail", name: "Mail", field: "user_mail", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "user_phone", name: "Phone", field: "user_phone", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "user_online", name: "Online", field: "user_online", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "user_enable", name: "Enabled", field: "user_enable", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "user_start_date", name: "Start Date", field: "user_start_date", width: 120, cssClass: "cell-title", editor: Slick.Editors.Date},
                    {id: "user_end_date", name: "End Date", field: "user_end_date", width: 120, cssClass: "cell-title", editor: Slick.Editors.Date},
                    {id: "user_del", name: 'Delete', field: "user_del", width: 250, formatter: buttonFormatter}
                ],

                // Options de la grid
                options = {
                    editable: true,
                    enableAddRow: true,
                    enableCellNavigation: true,
                    asyncEditorLoading: false,
                    autoEdit: false,
                    autoHeight: true
                },

                // Création des données
                data = [],

                // Permet de sauvegarder l'ancien user_id lorsque l'admin modifie un utilisateur du VPN
                save = null,

                grid = null;



            // Action lorsqu'on veut supprimer un user
            $('.del_user').live('click', function () {

                // Suppression dans la bdd
                var me = $(this), id = me.attr('id'),
                    data = grid.getData();

                $.ajax({
                    type: "POST",
                    url: "ajax.php",
                    dataType: "json",
                    data: {del_user_id: id},
                    error: function () {
                        alert("Erreur dans la suppression de la donnée...");
                    }
                });

                // Suppression de la ligne en question 
                data.splice(me.attr('data-row'), 1);
                grid.setData(data);
                grid.render();
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

            // Grille des utilisateurs du VPN
            grid = new Slick.Grid($("#grid_user"), data, columns, options);

            $("#grid_user").on('click', function () {
                var $active = grid.getActiveCell();

                if ($active !== undefined && $active.cell === 0) {
                    save = $(grid.getActiveCellNode()).html();
                } else {
                    save = null;
                }
            });

            // Lorsqu'on modifie une cellule d'un utilisateur
            grid.onCellChange.subscribe(function (e, args) {
                var item = args.item;

                // On sauvegarde l'ancien user_id
                if (save) {
                    item.set_user = save;
                } else {
                    item.set_user = item.user_id;
                }

                // Suppression dans la bdd
                $.ajax({
                    type: "POST",
                    url: "ajax.php",
                    dataType: "json",
                    data: item,
                    error: function () {
                        alert("Erreur dans la modification des données...");
                    }
                });

                delete item.set_user;
            });

            // Ajout d'un nouvel utilisateur
            grid.onAddNewRow.subscribe(function (e, args) {
                var item = args.item;

                // On ne peut ajouter un utilisateur qu'en saisissant son id
                if (!item.user_id) {
                    return;
                }

                // Modification dans la bdd
                item.add_user = true;

                $.ajax({
                    type: "POST",
                    url: "ajax.php",
                    dataType: "json",
                    data: item,
                    error: function () {
                        alert("Erreur dans l'insertion des données...");
                    }
                });

                delete item.add_user;

                // Maj de la grille
                grid.invalidateRow(data.length);
                data.push(item);
                grid.updateRowCount();
                grid.render();
            });

            grid.autosizeColumns();
        },
        error: function () {
            alert('Erreur dans la récupération des données...');
        }
    });

    // Selection des logs
    $.ajax({
        type: "POST",
        url: "ajax.php",
        dataType: 'json',
        data: "select=log",
        success: function (json) {
            var
                i,

                // Header des colonnes
                columns = [
                    {id: "log_id", name: "Log ID", field: "log_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "user_id", name: "User ID", field: "user_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_trusted_ip", name: "Trusted IP", field: "log_trusted_ip", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_trusted_port", name: "Trusted Port", field: "log_trusted_port", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_remote_ip", name: "Remote IP", field: "log_remote_ip", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_remote_port", name: "Remote Port", field: "log_remote_port", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_start_time", name: "Start Time", field: "log_start_time", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_end_time", name: "End Time", field: "log_end_time", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_received", name: "Receveid", field: "log_received", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "log_send", name: "Sent", field: "log_send", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text}
                ],

                // Options de la grille
                options = {
                    editable: false,
                    enableAddRow: false,
                    enableCellNavigation: true,
                    asyncEditorLoading: false,
                    autoEdit: false,
                    autoHeight: true
                },

                // Données de la grille des logs
                data = [],
                grid = null;

            for (i = 0; i < json.length; i += 1) {
                data[i] = {
                    log_id: json[i].log_id,
                    user_id: json[i].user_id,
                    log_trusted_ip: json[i].log_trusted_ip,
                    log_trusted_port: json[i].log_trusted_port,
                    log_remote_ip: json[i].log_remote_ip,
                    log_remote_port: json[i].log_remote_port,
                    log_start_time: json[i].log_start_time,
                    log_end_time: json[i].log_end_time,
                    log_received: json[i].log_received,
                    log_send: json[i].log_send
                };
            }

            // Création de la grille
            grid = new Slick.Grid($("#grid_log"), data, columns, options);

            grid.autosizeColumns();
        },
        error: function () {
            alert('Erreur dans la récupération des données...');
        }
    });


    // Selection des admins
    $.ajax({
        type: "POST",
        url: "ajax.php",
        dataType: 'json',
        data: "select=admin",
        success: function (json) {
            // Fonction créant la cellule pour supprimer un admin
            function buttonFormatter(row, cell, value, columnDef, dataContext) {  
                var button = "<img src='images/drop.png' class='delete del_admin' data-row='" + row + "' id='" + dataContext.admin_id + "' />";
                return button;
            }

            var
                i,

                // Header des colonnes
                columns = [
                    {id: "admin_id", name: "Admin ID", field: "admin_id", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "admin_pass", name: "Admin Pass", field: "admin_pass", width: 120, cssClass: "cell-title", editor: Slick.Editors.Text},
                    {id: "admin_del", name: 'Delete', field: "admin_del", width: 250, formatter: buttonFormatter}
                ],

                // Option de la grille
                options = {
                    editable: true,
                    enableAddRow: true,
                    enableCellNavigation: true,
                    asyncEditorLoading: false,
                    autoEdit: false,
                    autoHeight: true
                },

                data = [],
                grid = null,

                // Sauvegarder l'ancien admin_id lorsqu'on modifie un admin
                save = null;



            // Lorsqu'on veut supprimer un admin
            $('.del_admin').live('click', function () {
                // Suppression dans la bdd
                var me = $(this), id = me.attr('id'), data = grid.getData();
                $.ajax({
                    type: "POST",
                    url: "ajax.php",
                    dataType: "json",
                    data: {del_admin_id: id},
                    error: function () {
                        alert("Erreur dans la suppression de la donnée...");
                    }
                });

                // Maj de la grille
                data.splice(me.attr('data-row'), 1);
                grid.setData(data);
                grid.render();
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

                if ($active !== undefined && $active.cell === 0) {
                    save = $(grid.getActiveCellNode()).html();
                } else {
                    save = null;
                }
            });

            // Lorsqu'on modifie un admin
            grid.onCellChange.subscribe(function (e, args) {
                var item = args.item;

                // On stocke l'ancien admin_id
                if (save) {
                    item.set_admin = save;
                } else {
                    item.set_admin = item.admin_id;
                }

                // Modification de la bdd
                $.ajax({
                    type: "POST",
                    url: "ajax.php",
                    dataType: "json",
                    data: item,
                    error: function () {
                        alert("Erreur dans la modification des données...");
                    }
                });

                delete item.set_admin;
            });

            // Ajout d'un nouvel admin
            grid.onAddNewRow.subscribe(function (e, args) {
                var item = args.item;

                // On peut ajouter un admin seulement en ajoutant un ID
                if (!item.admin_id) {
                    return;
                }

                item.add_admin = true;

                // Maj de la bdd
                $.ajax({
                    type: "POST",
                    url: "ajax.php",
                    dataType: "json",
                    data: item,
                    error: function () {
                        alert("Erreur dans l'insertion des données...");
                    }
                });

                delete item.add_admin;

                // Maj de la grille
                grid.invalidateRow(data.length);
                data.push(item);
                grid.updateRowCount();
                grid.render();
            });

            grid.autosizeColumns();
        },
        error: function () {
            alert('Erreur dans la récupération des données...');
        }
    });
});
