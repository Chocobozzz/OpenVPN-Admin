<div class="row">
  <div class="col-md-5 col-md-offset-3">

    <form id="configuration_form" method="POST" class="panel panel-default">

      <div class="panel-heading">
        <h3 class="panel-title">Get the configuration files</h3>
      </div>

      <div class="panel-body">
        <div class="form-group">
          <label for="configuration_username">Username</label>
          <input type="text" id="configuration_username" name="configuration_username" class="form-control" autofocus/>
        </div>

        <div class="form-group">
          <label for="configuration_pass">Password</label>
          <input type="password" id="configuration_pass" name="configuration_pass" class="form-control" />
        </div>
        <input id="configuration_get" name="configuration_get" type="submit" value="ovpn Configuration File" class="btn btn-default" style="margin:10px;" />
        <input id="windows_instruction_get" name="windows_instruction_get" type="submit" value="Windows Instructions" class="btn btn-default" style="margin:10px;" />
        <input id="mac_instruction_get" name="mac_instruction_get" type="submit" value="MAC Instructions" class="btn btn-default" style="margin:10px;" />

      </div>

    </form>

  </div>
</div>
