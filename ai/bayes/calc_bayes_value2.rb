# This file will calculate the bayesian values for ema, macd and volume. It will also try to verify it's result with the latest date 
require 'mysql'
require 'date'

filename = Time.now().to_s + "22days_bayes.out" 
$stdout = File.new(filename, 'w')
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

con.close



