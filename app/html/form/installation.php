<div class="row">
  <div class="col-md-4 col-md-offset-4">

    <form id="install_form" method="POST" class="panel panel-default">

      <div class="panel-heading">
        <h3 class="panel-title">Installation</h3>
      </div>

      <div class="panel-body">
        <div class="form-group">
          <label for="admin_username">Admin username:</label>
          <input type="text" id="admin_username" name="admin_username" class="form-control" autofocus/>
        </div>

        <br /><br />

        <div class="form-group">
          <label for="admin_pass">Admin password:</label>
          <input type="password" id="admin_pass" name="admin_pass" class="form-control" />
        </div>

        <div class="form-group">
          <label for="repeat_admin_pass">Repeat the admin password:</label>
          <input type="password" id="repeat_admin_pass" name="repeat_admin_pass" class="form-control" />
        </div>

        <br /><br />

        <input id="install" name="install" type="submit" value="Install" class="btn btn-default" />
      </div>

    </form>

  </div>
</div>
