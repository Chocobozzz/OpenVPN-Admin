<!-- Users grid -->
<div class="block-grid row" id="user-grid">
  <h4>
    OpenVPN Users <button data-toggle="modal" data-target="#modal-user-add" type="button" class="btn btn-success btn-xs"><span class="glyphicon glyphicon-plus"></span></button>
  </h4>
  <table id="table-users" class="table"></table>

  <div id="modal-user-add" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title">Add user</h4>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="modal-user-add-username">Username</label>
            <input type="text" name="username" id="modal-user-add-username" class="form-control" autofocus/>
          </div>
          <div class="form-group">
            <label for="modal-user-add-password">Password</label>
            <input type="password" name="password" id="modal-user-add-password" class="form-control" />
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" id="modal-user-add-save">Save</button>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Logs grid -->
<div class="block-grid row" id="log-grid">
  <h4>
    OpenVPN logs
  </h4>
  <table id="table-logs" class="table"></table>
</div>

<!-- Admins grid -->
<div class="block-grid row" id="admin-grid">
  <h4>
    Web Admins <button data-toggle="modal" data-target="#modal-admin-add" type="button" class="btn btn-success btn-xs"><span class="glyphicon glyphicon-plus"></span></button>
  </h4>
  <table id="table-admins" class="table"></table>

  <div id="modal-admin-add" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title">Add admin</h4>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="modal-admin-add-username">Username</label>
            <input type="text" name="username" id="modal-admin-add-username" class="form-control" autofocus/>
          </div>
          <div class="form-group">
            <label for="modal-admin-add-password">Password</label>
            <input type="password" name="password" id="modal-admin-add-password" class="form-control" />
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" id="modal-admin-add-save">Save</button>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="/vendor/jquery/dist/jquery.min.js"></script>
<script src="/vendor/bootstrap/js/modal.js"></script>
<script src="/vendor/bootstrap/js/tooltip.js"></script>
<script src="/vendor/bootstrap/js/popover.js"></script>
<script src="/vendor/bootstrap-table/dist/bootstrap-table.min.js"></script>
<script src="/vendor/bootstrap-datepicker/dist/js/bootstrap-datepicker.js"></script>
<script src="/vendor/bootstrap-table/dist/extensions/editable/bootstrap-table-editable.min.js"></script>
<script src="/vendor/x-editable/dist/bootstrap3-editable/js/bootstrap-editable.js"></script>
<script src="/js/grids.js"></script>
