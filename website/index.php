<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" type="text/css" media="all" href="css/960.css" />
		<link rel="stylesheet" type="text/css" media="all" href="css/bootstrap.css" />
		<link rel="stylesheet" type="text/css" media="all" href="css/main.css" />
		<!--<link href='http://fonts.googleapis.com/css?family=Jura' rel='stylesheet' type='text/css'>-->
<script type="text/javascript" src="jquery.js"></script>
<script type="text/javascript" src="highstock/js/highstock.js"></script>
<script type="text/javascript">
var count = 0;
var series = new Array();
var stock = '<?php  echo $_GET['stock'] ?>';
//var stock = 'msft';
var createChart = function() {
	window.chart = new Highcharts.StockChart({
		chart : {
			renderTo : 'stock',
			width: 900
		},
		rangeSelector : {
			selected : 4
		},
		tooltip: {
			pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b><br/>',
				valueDecimals: 2
		},
		plotLines: [{
			value: 0,
				width: 2,
				color: 'silver'
		}],
		series : series
	});
};
$(function() {
	$.getJSON('../webservice/index.php?stock=' + stock, function(data) {
		series.push({'name': stock, 'data': data });
		count++;
					if(count == 1) {
						createChart();
					}
				});

				$.getJSON('../webservice/predictions.php?stock=' + stock, function(data) {
					series.push({'name': stock + ' Prediction', 'data': data });
					count++;
					if(count == 1) {
						createChart();
					}
				});

				$.getJSON('../webservice/company.php?stock=' + stock, function(data) {
					document.title = data.name;
					console.log(data);
					$('#company_name').text(data.name);
				});

			});
		</script>
		  <script>
  
  $(document).ready(function(){
    var stock = '<?php echo $_GET['stock'] ?>'; 
   // var stock = 'xata';
		$.ajax({
        url: '../webservice/bayes.php',
        data: 'stock=' + stock,
        dataType: 'json' 
      }).done(function(data) {
        var total_up = 1;
        var total_down = 1;
        var e = parseInt(data[0]);
        var m = parseInt(data[1]);
        var v = parseInt(data[2]);
        if(e) {
        
          total_up *= data['3']/100;
          total_down *= data['4']/100;

          $("#ema_msg").html("");
          $("#ema_up").html(parseFloat(data['3']).toFixed(2) + "% UP"); 
          $("#ema_down").html(parseFloat(data['4']).toFixed(2) + "% DOWN"); 
          
        } 
        if(m) {
          
          total_up *= data['5']/100;
          total_down *= data['6']/100;

          $("#macd_msg").html("");
          $("#macd_up").html(parseFloat(data['5']).toFixed(2) + "% UP");  
          $("#macd_down").html(parseFloat(data['6']).toFixed(2) + "% DOWN");  
        }
        if(v) {

          total_up *= data['7']/100;
          total_down *= data['8']/100;

          $("#volume_msg").html("");
          $("#volume_up").html(parseFloat(data['7']).toFixed(2) + "% UP");  
          $("#volume_down").html(parseFloat(data['8']).toFixed(2) + "% DOWN");
        }
        var tmp_up, tmp_down; 
        tmp_up = total_up/(total_up + total_down);
        tmp_down = total_down/(total_up + total_down);
        total_up = tmp_up;
        total_down = tmp_down;
        if(e || m || v) {
          $('#total_up').html(parseFloat(total_up*100).toFixed(2) + "%");
          $('#total_down').html(parseFloat(total_down*100).toFixed(2) + "%");
      
          if(parseFloat(total_up*100).toFixed(2) > parseFloat(total_down*100).toFixed(2) ) {
            $('#indicator').html('UP');
          } else {
            $('#indicator').html('DOWN');
          } 
        } 
      });
  }); 
		</script>
	</head>
	<body>
			<div class="" id="header">
				<h1 id="title">Limitless</h1>
			</div>
		<div class="container_12">	
			<div class="clear spacer"></div> 
			<div class="grid_12" id="stock_graph">
			<h1>
			<span id="company_name">
			</span>
			<span id="indicator"> </span>
			</h1>
	
			<div class="clear spacer"></div> 

				<div class="grid_8" id="stock">
				</div>
				<div class="grid_8">
				</div>
				<div class="grid_8">
				</div>
			</div>
		  <div class="grid_12" id="ai_data">
 			 
 			   <div class="grid_12" id="total_prob">
 			      <div class="">Total Probability Up: <span id="total_up"></span></div>
 			   </div>


				<div class="grid_4 bayesData">
 			     <h2>EMA</h2>
 			       <div class="" id="ema_msg"> NO INDICATOR </div>
 			       <div class="" id="ema_up"></div>  
 			       <div class="" id="ema_down"></div>
 			       <div class="" id="ema"></div>
 			   </div>
 			   <div class="grid_4 bayesData">
 			     <h2>MACD</h2>
 			       <div class="" id="macd_msg"> NO INDICATOR</div>
 			       <div class="" id="macd_up"></div> 
 			       <div class="" id="macd_down"></div>
 			       <div class="" id="macd"></div>
 			   </div>
 			   <div class="grid_3 bayesData">
 			     <h2>VOLUME</h2>
 			       <div class="" id="volume_msg"> NO INDICATOR</div>
 			       <div class="" id="volume_up"></div>  
 			       <div class="" id="volume_down"></div>
 			       <div class="" id="volume"></div>
 			   </div>
 			   <div class="clear spacer"></div>  
 			 </div>  
 			   
 			 <div class="clear spacer"></div> 
	</div>
 	<div class="" id="footer">  
<div id="footercontent">
 		<div> San Jose State University </div>
		<div> Minh Nguyen </div>
		<div> Chuma Nnaji </div>
	</div>
	</div>
	</body>
</html>
