<?php
mysql_connect('localhost', 'root', 'denny') or die("mysql connect: " . mysql_error());
mysql_select_db('limitless');
$stock = $_GET['stock'];
$sql = 'select name FROM companies WHERE symbol = "' . strtoupper($stock) . '"';
$res = mysql_query($sql) or die(mysql_error());
echo json_encode(mysql_fetch_assoc($res));
?>
