<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" type="text/css" media="all" href="css/960.css" />
		<link rel="stylesheet" type="text/css" media="all" href="css/main.css" />
		<!--<link href='http://fonts.googleapis.com/css?family=Jura' rel='stylesheet' type='text/css'>-->
		<script type="text/javascript" src="jquery.js"></script>
		<script type="text/javascript" src="highstock/js/highstock.js"></script>
		<script type="text/javascript">
			var count = 0;
			var series = new Array();
			var stock = '<?= $_GET['stock'] ?>';
			var createChart = function() {
				window.chart = new Highcharts.StockChart({
					chart : {
						renderTo : 'stock'
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
				$.getJSON('/limitless/webservice/index.php?stock=' + stock, function(data) {
					series.push({'name': stock, 'data': data });
					count++;
					if(count == 2) {
						createChart();
					}
				});

				$.getJSON('/limitless/webservice/predictions.php?stock=' + stock, function(data) {
					series.push({'name': stock + ' Prediction', 'data': data });
					count++;
					if(count == 2) {
						createChart();
					}
				});

				$.getJSON('/limitless/webservice/company.php?stock=' + stock, function(data) {
					document.title = data.name;
					console.log(data);
					$('#company_name').text(data.name);
				});
			});
		</script>
	</head>
	<body>
		<div class="container_12">	
			<div class="grid_12" id="header">
				<h1 id="title">Limitless</h1>
			</div>
			<div class="clear spacer"></div> 
			<div class="grid_8" id="stock_graph">
			<h1 id="company_name"></h1>
<!--
				<div class="grid_8" id="nav">
					<div class="grid_1 nav-box"><div class="grid_1 nav-item" >One</div> </div> 
					<div class="grid_1 nav-box"><div class="grid_1 nav-item" >Two</div> </div>
					<div class="grid_1 nav-box"><div class="grid_1 nav-item" >Three</div></div> 
					<div class="grid_1 nav-box"><div class="grid_1 nav-item" >Four</div></div> 
					<div class="grid_1 nav-box"><div class="grid_1 nav-item" >Five</div></div>
				</div>
-->
				<div class="clear spacer"></div> 

				<div class="grid_8" id="stock">
				</div>
				<div class="grid_8">
					VOLUME GRAPH
				</div>
				<div class="grid_8">
					MACD GRAPH
				</div>
			</div>
			<div class="grid_4" id="ai_data">
				<h1> Groovy Analysis </h1>
				<div class="grid_4">
					<h2>MACD</h2>
					<div class="grid_4">mean =  </div>	
					<div class="grid_4">std. div =  </div>
					<div class="grid_4">Probabilty of MACD =  </div>
				</div>
				<div class="grid_4">
					<h2>Volume</h2>
					<div class="grid_4">mean =  </div>  
					<div class="grid_4">std. div =  </div>
					<div class="grid_4">Probabilty of Volume =  </div>
				</div>
				<div class="grid_4">
					<h2>EMA</h2>
					<div class="grid_4">mean =  </div>  
					<div class="grid_4">std. div =  </div>
					<div class="grid_4">Probabilty of EMA =  </div>
				</div>
				<div class="grid_4">
					<h2>Total Probability</h2>
					<div class="grid_4" >Total probability =  </div>
				</div>
				<div class="clear spacer"></div>	
			</div>	

			<div class="clear spacer"></div> 
			<div class="grid_12" id="footer">  
			</div>  
		</div>
	</body>
</html>
