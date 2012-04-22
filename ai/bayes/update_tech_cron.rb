require 'mysql'
require 'date'

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

#put initial default price for yesterday ema
syes = 1
lyes = 1
slyes = 1
myes = 1
SDAY = 12
SLDAY = 22
LDAY = 200
MDAY = 9
startDate = Time.new.to_date - 31
#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')
rs = con.query('show tables')
rs.each_hash { |h|
										
										if h['Tables_in_limitless'] =~ /^company_.*/
										q = con.query("select * from #{h['Tables_in_limitless']} where date > '#{startDate.year}-#{startDate.month}-#{startDate.day}' order by date")
										table = h['Tables_in_limitless']
										q.each_hash { |a|
																			row = a['date']
																			cur_price = a['close_price']
																			#calculate the short & long EMA; short long ema for signal calculation
																			sema = calcEMA(cur_price, SDAY, syes)
																			slema = calcEMA(cur_price, SLDAY, slyes)
																			lema = calcEMA(cur_price, LDAY, lyes)
																			
																			#save the ema for tomorrow's calculation
																			syes = sema
																			slyes = slema
																			lyes = lema

																			#calculate MACD, Signal line & Histogram
																			macd = calcMACD(sema, slema)
																			signal = calcEMA(macd, MDAY, myes)
																			myes = signal
																			hist = calcHistogram(macd, signal)
#																			tech = con.query("UPDATE #{table} set short_ema=#{sema}, long_ema=#{lema}, macd=#{macd}, signal_line=#{signal}, histogram=#{hist} WHERE date='#{row}'") 
																			puts "#{table} #{row}  short ema: #{sema} long ema: #{lema} macd: #{macd} signal line: #{signal} histogram: #{hist}"
																}
								end
								}


con.close
