#this file will look at 2011 and find a lookahead value that will yeild the highest percentage
require 'mysql'
require 'date'
$stdout = File.new('console.out', 'w')
$stdout.sync = true
# constants
syes = 1 
lyes = 1 
slyes = 1 
myes = 1 
SDAY = 12
SLDAY = 22
LDAY = 200 
MDAY = 9 

#probability density function f(x) = 1/[sqrt(2pi)*o] * e^((x-u)^2/(2o^2))
def prob(x, u, o)
  f = (1/(Math.sqrt(2*Math::PI)*o.to_f))*(Math::E)**((((x.to_f - u.to_f)**2)/(2*o.to_f**2))*-1)
end

# calculate functions!!! :) wheeeeeeee!
def calcEMA(todayPrice, numOfdays, emaYesterday)
  k = 2/(numOfdays.to_f+1)
  todayPrice.to_f*k.to_f + emaYesterday.to_f*(1-k.to_f)
end

def calcMACD(shortEMA, longEMA)
  shortEMA.to_f - longEMA.to_f
end

def calcHistogram(macd, signal)
  macd.to_f - signal.to_f
end

top_dateE = ""
top_hE = 0
top_lE = 1
top_lookE = 30

top_dateM = ""
top_hM = 0
top_lM = 1
top_lookM = 30

top_datev = ""
top_hv = 0
top_lv = 1 
top_lookv = 30
p_gain = 3
z = 30
d_lookahead = z
#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')
for i in 1..8
	for j in 1..25
		z = 30
		while z < 60			
fema_up = 0
fema_down = 0
fmacd_up = 0
fmacd_down = 0
fv_up = 0
fv_down = 0
d = ""
d_lookahead = z
all = con.query("show tables")
all.each_hash { |h|

	unless h['Tables_in_limitless'] == 'industries' || h['Tables_in_limitless'] == 'companies' || h['Tables_in_limitless'] == 'ema22' || h['Tables_in_limitless'] == 'volume5050' || h['Tables_in_limitless'] == 'macd22'
	month  = i
	day = j
	d = Date.new(2011,month.to_i,day.to_i)
	q = con.query("select * from #{h['Tables_in_limitless']} where date='#{d}'")
	table = h['Tables_in_limitless']
	q.each_hash { |e| 
		c = e['macd']
		c_macd = e['histogram'].to_f
    if c.to_f < '0.50'.to_f && c.to_f > 0 
      s = e['date'].split('-')
      date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + d_lookahead.to_i 
      cur_price = e['close_price']
      theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
      theFUTURE.each_hash { |f1|
                                price = f1['close_price'].to_f - cur_price.to_f 
                                price = price.to_f/cur_price.to_f 
                                price *= 100 
                                if price > 5 
                                  fema_up += 1
                                else
                                  fema_down += 1
                                end 
                          }   
    # puts "EMA #{table} UP prob: #{bayes} Down prob: #{nbayes}"      
    end 
    if c_macd.to_f < '0.05'.to_f && c_macd.to_f > 0 
      s = e['date'].split('-')
      date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + d_lookahead.to_i  
      cur_price1 = e['close_price']
      theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
      theFUTURE.each_hash { |f1|
                                price1 = f1['close_price'].to_f - cur_price1.to_f
                                price1 = price1.to_f/cur_price1.to_f
                                price1 *= 100 
                                if price1 > 5 
                                  fmacd_up += 1
                                else
                                  fmacd_down += 1
                                end 
                          }   
   # puts "MACD #{table} UP prob: #{upMac} Down prob: #{downMac}" 
    end 	
		name = h['Tables_in_limitless'].split('_',2)	
		volume = e['volume']
		compavg = con.query("select * from companies where symbol='#{name[1]}' LIMIT 1") 
    avg = 0;
    compavg.each_hash { |v| 
    	avg = v['avg_volume'].to_f
  	}				
	  unless avg.nan?
			high_v = ((volume.to_f - avg.to_f)/volume.to_f) * 100
			op = e['open_price']
      cp = e['close_price']
      pp = ((cp.to_f - op.to_f)/cp.to_f) * 100 		
			if high_v > 25 && pp > 1 
				s = e['date'].split('-')
      	date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + d_lookahead.to_i 
      	cur_price = e['close_price']
      	theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
      	theFUTURE.each_hash { |f1|
                                price = f1['close_price'].to_f - cur_price.to_f
                                price = price.to_f/cur_price.to_f
                                price *= 100
                                if price.to_i > p_gain.to_i
                                  fv_up += 1
                                else
                                  fv_down += 1
                                end
                          }
	#			puts "volume"
			end
		end			

	}

	end # unless statement
}

puts "#{d} lookahead #{z}:"
puts "#{fema_up} #{fema_down} percentage ema up #{(fema_up.to_f)/(fema_up.to_f+fema_down.to_f)} down: #{(fema_down.to_f)/(fema_up.to_f+fema_down.to_f)}"
puts "#{fmacd_up} #{fmacd_down} percentage macd up #{(fmacd_up.to_f)/(fmacd_up.to_f+fmacd_down.to_f)} down: #{(fmacd_down.to_f)/(fmacd_up.to_f+fmacd_down.to_f)}"
puts "#{fv_up} #{fv_down} percentage volume up #{(fv_up.to_f)/(fv_up.to_f+fv_down.to_f)} down: #{(fv_down.to_f)/(fv_up.to_f+fv_down.to_f)}"
	if (fema_up.to_f)/(fema_up.to_f+fema_down.to_f) > (top_hE.to_f)/(top_hE.to_f + top_lE.to_f)
		top_dateE = d
		top_hE = fema_up
		top_lE = fema_down	
		top_lookE = d_lookahead
	end
	if (fmacd_up.to_f)/(fmacd_up.to_f+fmacd_down.to_f) > (top_hM.to_f)/(top_hM.to_f + top_lM.to_f)
		top_dateM = d
		top_hM = fmacd_up
		top_lM = fmacd_down
		top_lookM = d_lookahead
	end
	if (fv_up.to_f)/(fv_up.to_f+fv_down.to_f) >  (top_hv.to_f)/(top_hv.to_f + top_lv.to_f)
		top_datev = d
		top_hv = fv_up
		top_lv = fv_down	
		top_lookv = d_lookahead
	end
puts "-------------------------HIGH Performance-------------------------"
puts "EMA date: #{top_dateE} lookahead: #{top_lookE} up: #{(top_hE.to_f)/(top_hE.to_f + top_lE.to_f)} down: #{(top_lE.to_f)/(top_hE.to_f + top_lE.to_f)}"
puts "MACD date: #{top_dateM} lookahead: #{top_lookM} up: #{(top_hM.to_f)/(top_hM.to_f + top_lM.to_f)} down: #{(top_lM.to_f)/(top_hM.to_f + top_lM.to_f)}"
puts "VOLUME date: #{top_datev} lookahead: #{top_lookv} up: #{(top_hv.to_f)/(top_hv.to_f + top_lv.to_f)} down: #{(top_lv.to_f)/(top_hv.to_f + top_lv.to_f)}"
				z += 7 # look ahead increment 
			end # while loop lookahead
 		end #for loop day
	end # for loop month
con.close



