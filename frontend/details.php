<?php

// GET args handed over
$args = $_POST;
?>
<!DOCTYPE HTML>
<html>
  <head>
    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <link href="css/bootstrap.min.css" rel="stylesheet" />

    <style>
      body {
          background-color: black;
          color: white;
      }
      .tab-pane img {
          width: 100%;
      }
    </style>

    <title>ERA5 Visualization</title>
  </head>
<body id="details-content">
    <!-- Nav tabs -->
    <ul class="nav nav-tabs">
      <li class="nav-item">
        <a class="nav-link active" data-bs-toggle="tab" href="#img2t">Temperatur</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" data-bs-toggle="tab" href="#imgtp">Niederschlag</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" data-bs-toggle="tab" href="#img3">Bodenwassergehalt</a>
      </li>
    </ul>

    <!-- Tab panes -->
    <div class="tab-content">
      <div class="tab-pane container-fluid active" id="img2t">
        <img src="timeseries/2t_Innsbruck_Austria.svg" alt="Innsbruck" />
      </div>
      <div class="tab-pane container-fluid fade" id="imgtp">
        FOO
      </div>
      <div class="tab-pane container-fluid fade" id="img3">
            BAR
      </div>
    </div>

</body>

</html>


