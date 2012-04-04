# This file will calculate the bayesian values for ema, macd and volume. It will also try to verify it's result with the latest date 
require 'mysql'
require 'date'

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



#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')
ema_y = 0
ema_n = 0
ema_t = 0
ema22 = con.query('select * from ema22')
ema22.each_hash { |h|
	ema_t += 1
	if h['up'].to_f == 1
		ema_y += 1
	else
		ema_n += 1
	end
}

macd_y = 0
macd_n = 0
macd_t = 0
macd22 = con.query('select * from macd22')
macd22.each_hash { |h|
	macd_t += 1
	if h['up'].to_f == 1
    macd_y += 1
  else
    macd_n += 1
  end 
}

v_y = 0
v_n = 0
v_t = 0
volume5050 = con.query('select * from volume5050')
volume5050.each_hash { |h| 
	v_t += 1
	if h['up'].to_f == 1
		v_y += 1
	else
		v_n += 1
	end
}
puts "ema total:#{ema_t} yes: #{(ema_y.to_f/ema_t.to_f)*100} no: #{(ema_n.to_f/ema_t.to_f)*100}"
puts "macd total: #{macd_t} yes: #{(macd_y.to_f/macd_t.to_f)*100} no: #{(macd_n.to_f/macd_t.to_f)*100}"
puts "volume total: #{v_t} yes: #{(v_y.to_f/v_t.to_f)*100} no: #{(v_n.to_f/v_t.to_f)*100}"
q = con.query("insert into bayes_prediction_22days (ema_total, ema_up, ema_down, macd_total, macd_up, macd_down, v_total, v_up, v_down) VALUES ('#{ema_t}', '#{(ema_y.to_f/ema_t.to_f)*100}', '#{(ema_n.to_f/ema_t.to_f)*100}', '#{macd_t}',  '#{(macd_y.to_f/macd_t.to_f)*100}', '#{(macd_n.to_f/macd_t.to_f)*100}', '#{v_t}', '#{(v_y.to_f/v_t.to_f)*100}', '#{(v_n.to_f/v_t.to_f)*100}')") 

# No check current date of 2011-01-18
fema_up = 0
fema_down = 0
fmacd_up = 0
fmacd_down = 0
fv_up = 0
fv_down = 0

d_lookahead = 44
p_gain = 3
all = con.query("show tables")
all.each_hash { |h|

	if h['Tables_in_limitless'] =~ /company_.*/
	q = con.query("select * from #{h['Tables_in_limitless']} where date='2011-01-18'")
	table = h['Tables_in_limitless']
	q.each_hash { |e| 
		c = e['macd']
		c_macd = e['histogram'].to_f
		if c.to_f < '0.50'.to_f && c.to_f > 0
			bayes = (ema_y.to_f/ema_t.to_f) * 100
			nbayes = (ema_n.to_f/ema_t.to_f)*100
			s = e['date'].split('-')
			date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + d_lookahead.to_i 
			cur_price = e['close_price']
			theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
			theFUTURE.each_hash { |f1|
                               	price = f1['close_price'].to_f - cur_price.to_f 
                                price = price.to_f/cur_price.to_f 
                               	price *= 100 
                                if price > p_gain.to_i 
																	fema_up += 1
																else
																	fema_down += 1
																end
													}
		#	puts "EMA #{table} UP prob: #{bayes} Down prob: #{nbayes}"			
		end
		if c_macd.to_f < '0.05'.to_f && c_macd.to_f > 0
			upMac = (macd_y.to_f/macd_t.to_f) * 100 
      downMac = (macd_n.to_f/macd_t.to_f) * 100 
      s = e['date'].split('-')
      date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + d_lookahead.to_i 
      cur_price1 = e['close_price']
      theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
      theFUTURE.each_hash { |f1|
                                price1 = f1['close_price'].to_f - cur_price1.to_f
                                price1 = price1.to_f/cur_price1.to_f
                                price1 *= 100
                                if price1 > p_gain.to_i 
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
                                if price > p_gain.to_i 
                                  fv_up += 1
                                else
                                  fv_down += 1
                                end
                          }
	#			puts "volume"
			end
		end			

	}
	end
}

puts "Current values: "
puts "#{fema_up} #{fema_down} percentage ema up #{(fema_up.to_f)/(fema_up.to_f+fema_down.to_f)} down: #{(fema_down.to_f)/(fema_up.to_f+fema_down.to_f)}"
puts "#{fmacd_up} #{fmacd_down} percentage macd up #{(fmacd_up.to_f)/(fmacd_up.to_f+fmacd_down.to_f)} down: #{(fmacd_down.to_f)/(fmacd_up.to_f+fmacd_down.to_f)}"
puts "#{fv_up} #{fv_down} percentage volume up #{(fv_up.to_f)/(fv_up.to_f+fv_down.to_f)} down: #{(fv_down.to_f)/(fv_up.to_f+fv_down.to_f)}"
 
con.close



