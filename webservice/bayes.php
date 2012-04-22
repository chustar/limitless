<?php
// JSON data structure 
// 0: ema indicator (1 means it has the attribute, 0 otherwise)
// 1: macd indicator (1 means it has the attribute, 0 otherwise)
// 2: volume indicator (1 means it has the attribute, 0 otherwise, -1 means table doesn't have average)
// 3: ema up percentage
// 4: ema down percentage
// 5: macd up percentage
// 6: mad down percentage
// 7: volume up percentage
// 8: volume down percentage

// set the default timezone to use. Available since PHP 5.1
date_default_timezone_set('UTC');

mysql_connect('localhost', 'root', '') or die("mysql connect: " . mysql_error());
mysql_select_db('limitless');
$all = array();
$stock = $_GET['stock'];


//query statements for bayes analysis
$sql_get_date = 'select date from company_' . strtoupper($stock) . ' ORDER BY date desc LIMIT 1';
$sql_avg_volume = 'select avg_volume from companies where symbol=' . "'" . strtoupper($stock) . "'";
$sql_stats = 'select * from bayes_prediction';

//get latest date for analysis
$res = mysql_query($sql_get_date) or die(mysql_error());
while ($arr = mysql_fetch_array($res, MYSQL_ASSOC)) {
	$cur_date = $arr['date'];
}
$sql_stock = 'select macd, histogram, volume from company_' . strtoupper($stock) . ' where date='. "'" . $cur_date . "'" .' ORDER BY date ASC';

//echo $cur_date . " ";
$p_date = split("-",$cur_date);
$past = $p_date[0] . '-' . $p_date[1] . '-' . ($p_date[2].to_i - 1);
//echo $past . " ";
$sql_stock2 = 'select macd, histogram, volume from company_' . strtoupper($stock) . ' where date='. "'" . $past . "'" .' ORDER BY date ASC';

$PMACD = '';
$PEMA = '';

$res = mysql_query($sql_stock2) or die(mysql_error());
while ( $arr = mysql_fetch_array($res, MYSQL_ASSOC) ) {
$PMACD = $arr['macd'];  	
$PEMA = $arr['histogram'];  	
}

//echo $PMACD . " ";
//echo $PEMA . " ";


//get average volume to compare with latest company's statistics
$res = mysql_query($sql_avg_volume) or die(mysql_error());
while( $arr = mysql_fetch_array($res, MYSQL_ASSOC)) {
	$avg_volume = $arr['avg_volume'];
}

//get current stock data and assign prediction
// 1 = follows past prediction
// 0 = doesn't follow past prediction
// -1 = prediction cannot be made
$avg_set = isset($avg_volume);
$res = mysql_query($sql_stock) or die (mysql_error());
while ( $arr = mysql_fetch_array($res, MYSQL_ASSOC)) {
//	echo $arr['macd'] . " ";
//	echo $arr['histogram'] . " ";
	//ema analysis
	if($PEMA < 0 && $arr['macd'] > 0) {
		$all[] = "1";
	} else {
		$all[] = "0";
	}

	//macd analysis
	if ($PMACD < 0 && $arr['histogram'] > 0) {
		$all[] = "1";
	} else {
		$all[] = "0";
	}

	//volume analysis
	if($avg_set) {
		$high_vol = (($arr['volume'] - $avg_volume)/$arr['volume'])*100;
		if( $high_vol > 25) {
			$all[] = "1";	
		} else {
			$all[] = "0";
		}
	} else {
		$all[] = "-1";
	}
}

//get bayes prediction values based on past history
$res = mysql_query($sql_stats) or die(mysql_error());
while ($arr = mysql_fetch_array($res, MYSQL_NUM)) {
		$ema_up =   (string)$arr[1];
		$ema_down =  (string)$arr[2];
		$macd_up =  (string)$arr[4];
		$macd_down =  (string)$arr[5];
		$v_up =  (string)$arr[7];
		$v_down =  (string)$arr[8];
		$all[] = $ema_up; 
		$all[] = $ema_down;
		$all[] = $macd_up;
		$all[] = $macd_down;
		$all[] = $v_up;
		$all[] = $v_down;
}	

echo json_encode($all, JSON_FORCE_OBJECT);
?>
