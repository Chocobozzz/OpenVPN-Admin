<div class="col-md-6 col-md-offset-3">
  <nav class="navbar navbar-default">

    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav">
        <li <?php if(!isset($_GET['admin'])) echo 'class="active"'; ?>><a href="index.php">Configurations</a></li>
        <li <?php if(isset($_GET['admin'])) echo 'class="active"'; ?>><a href="index.php?admin">Administrator</a></li>
      </ul>
    </div>

  </nav>
</div>
