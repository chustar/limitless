<?php
mysql_connect('localhost', 'root', '') or die("mysql connect: " . mysql_error());
mysql_select_db('limitless');
$stock = $_GET['stock'];
$sql = 'select UNIX_TIMESTAMP(date), close_price from weka_prediction_company_' . strtoupper($stock) . ' ORDER BY date ASC';
$res = mysql_query($sql) or die(mysql_error());
$all = array();
while ($arr = mysql_fetch_array($res, MYSQL_NUM)) {
	$arr[0] = intval($arr[0])*1000;
	$arr[1] = floatval($arr[1]);
	$all[] = $arr;
}
echo json_encode($all);
?>
