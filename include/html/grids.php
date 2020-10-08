<?php
function getHistory($cfg_file, $accordion_id, $open_first_history_tab = false) {
   ob_start(); ?>
   <h3>History</h3>
   <div class="panel-group" id="accordion<?= $accordion_id ?>">
      <?php foreach (array_reverse(glob('client-conf/'.basename(pathinfo($cfg_file, PATHINFO_DIRNAME)).'/history/*')) as $i => $file): ?>
         <div class="panel panel-default">
            <div class="panel-heading">
               <h4 class="panel-title">
                  <a data-toggle="collapse" data-parent="#accordion<?= $accordion_id ?>" href="#collapse<?= $accordion_id ?>-<?= $i ?>">
                     <?php
                     $history_file_name = basename($file);
                     $chunks = explode('_', $history_file_name);
                     printf('[%s] %s', date('r', $chunks[0]), $chunks[1]);
                     ?>
                  </a>
               </h4>
            </div>
            <div id="collapse<?= $accordion_id ?>-<?= $i ?>" class="panel-collapse collapse <?= $i===0 && $open_first_history_tab?'in':'' ?>">
               <div class="panel-body"><pre><?= file_get_contents($file) ?></pre></div>
            </div>
         </div>
      <?php endforeach; ?>
   </div><?php
   $history = ob_get_contents();
   ob_end_clean();
   return $history;
}
?>
<ul class="nav nav-tabs">
   <li class="active"><a data-toggle="tab" href="#menu0"><span class="glyphicon glyphicon-user" aria-hidden="true"></span> OpenVPN Users</a></li>
   <li><a data-toggle="tab" href="#menu1"><span class="glyphicon glyphicon-book" aria-hidden="true"></span> OpenVPN logs</a></li>
   <li><a data-toggle="tab" href="#menu2"><span class="glyphicon glyphicon-king" aria-hidden="true"></span> Web Admins</a></li>
   <li><a data-toggle="tab" href="#menu3"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span> Configs</a></li>
</ul>
<div class="tab-content">

   <div id="menu0" class="tab-pane fade in active">
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
   </div>

   <div id="menu1" class="tab-pane fade">
      <!-- Logs grid -->
      <div class="block-grid row" id="log-grid">
         <h4>
            OpenVPN logs
         </h4>
         <table id="table-logs" class="table" data-filter-control="true"></table>
      </div>
   </div>

   <div id="menu2" class="tab-pane fade">
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
   </div>

   <div id="menu3" class="tab-pane fade">
      <!-- configs -->
      <div class="block-grid row" id="config-cards">
         <ul class="nav nav-tabs nav-tabs-justified">
            <li class="active"><a data-toggle="tab" href="#menu-1-0"><span class="glyphicon glyphicon-heart" aria-hidden="true"></span> Linux</a></li>
            <li><a data-toggle="tab" href="#menu-1-1"><span class="glyphicon glyphicon-th-large" aria-hidden="true"></span> Windows</a></li>
            <li><a data-toggle="tab" href="#menu-1-2"><span class="glyphicon glyphicon-apple" aria-hidden="true"></span> OSX</a></li>

            <li id="save-config-btn" class="pull-right hidden"><a class="progress-bar-striped" href="javascript:;"><span class="glyphicon glyphicon-save" aria-hidden="true"></span></a></li>
         </ul>
         <div class="tab-content">
            <div id="menu-1-0" class="tab-pane fade in active">

               <textarea class="form-control" data-config-file="<?= $cfg_file='client-conf/gnu-linux/client.ovpn' ?>" name="" id="" cols="30" rows="20"><?= file_get_contents($cfg_file) ?></textarea>
               <?= getHistory($cfg_file, @++$accId) ?>

            </div>
            <div id="menu-1-1" class="tab-pane fade">

               <textarea class="form-control" data-config-file="<?= $cfg_file='client-conf/windows/client.ovpn' ?>" name="" id="" cols="30" rows="20"><?= file_get_contents($cfg_file) ?></textarea>
               <?= getHistory($cfg_file, ++$accId) ?>

            </div>
            <div id="menu-1-2" class="tab-pane fade">

               <textarea class="form-control" data-config-file="<?= $cfg_file='client-conf/osx-viscosity/client.ovpn' ?>" name="" id="" cols="30" rows="20"><?= file_get_contents($cfg_file) ?></textarea>
               <?= getHistory($cfg_file, ++$accId) ?>

            </div>
         </div>

      </div>
   </div>

</div>

<script src="vendor/jquery/dist/jquery.min.js"></script>
<script src="vendor/bootstrap/js/modal.js"></script>
<script src="vendor/bootstrap/js/tooltip.js"></script>
<script src="vendor/bootstrap/js/tab.js"></script>
<script src="vendor/bootstrap/js/collapse.js"></script>
<script src="vendor/bootstrap/js/popover.js"></script>
<script src="vendor/bootstrap-table/dist/bootstrap-table.min.js"></script>
<script src="vendor/bootstrap-datepicker/dist/js/bootstrap-datepicker.js"></script>
<script src="vendor/bootstrap-table/dist/extensions/editable/bootstrap-table-editable.min.js"></script>
<script src="vendor/bootstrap-table/dist/extensions/filter-control/bootstrap-table-filter-control.min.js"></script>
<script src="vendor/x-editable/dist/bootstrap3-editable/js/bootstrap-editable.js"></script>
<script src="js/grids.js"></script>

<script>
$(document).ready(function(){
   /*
   https://stackoverflow.com/a/19015027/3214501
   -> keep the currently active tab beyond page reloading
   */
   $('.nav.nav-tabs a').click(function(e) {
     e.preventDefault();
     $(this).tab('show');
   });
   $("ul.nav-tabs > li > a").on("shown.bs.tab", function(e) {
     var id = $(e.target).attr("href").substr(1);
     window.location.hash = id;
   });
   $('.nav.nav-tabs a[href="' + window.location.hash + '"]').tab('show');
});
</script>
