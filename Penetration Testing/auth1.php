<?php
	include_once 'header.php';
	if (!isset($_SESSION['u_id'])) {
	header("Location: home.php");
	} else {
		$user_id = $_SESSION['u_id']; 
		$user_uid = $_SESSION['u_uid'];
	}
?>
        <section class="main-container">
            <div class="main-wrapper">
                <h2>Auth page 1</h2>
				Only authenticated users should be able to see this Page(1).
            </div>
        </section>
	
<?php	
	echo "<br>";
	//Reflect user's name on the page
	if(isset($_SESSION['u_id'])) {
		$user_uid = $_SESSION['u_uid'];
		echo "You're logged in as " . cleanChars($user_uid);
	}

	function cleanChars($val)
	{
	return $val;
	}
?>

<html>

<!-- https://hackersonlineclub.com/command-injection-cheatsheet/

Objectives
1. Obtain the directory structure on the server
2. obtain the network configuration of the server
3. Upload a file that will execuite on the server (.php file parhaps)
4. Run the file -->

<head>

</head>


<div class="header">

</div>

<div class="clearfix">
  <div class="column menu">

  </div>

  <div class="column content">
	<p></p>


  </div> 
  
  <div class="column content">
  <p><br>Enter your IP/host to ping.  
            <form method='get' action=''>
                <div class="form-group"> 
                    <label></label>
                    <input class="form-control" width="50%" placeholder="" name="target"></input> <br>
                    <div align="left"> <button class="btn btn-default" type="submit">Submit Button</button></div>
               </div> 
            </form>
	</p>

  <?php

	try {

		if (isset($_REQUEST['target'])) {
			$target = $_REQUEST['target'];
			//echo &target;
			if($target){
				if (stristr(php_uname('s'), 'Windows NT')) { 
				   $cmd = shell_exec( 'ping  ' . $target );
					echo '<pre>'.$cmd.'</pre>';
					} else { 
						$cmd = shell_exec( 'ping  -c 3 ' . $target );
						echo '<pre>'.$cmd.'</pre>';
					}
				}
			}             
		}
	catch(Exception $e) {
		echo '<BR> Pass your payload to a parameter called name on the URL (HTTP GET request) ';
		echo '<BR><p><b>Example:</b>    http://localhost/Lab/dt/dt.php?target=IPaddress </p>';	
	}

	?>
	</div>
	
</div>

<div class="footer">
</div>

</body>
</html>



