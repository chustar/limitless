require 'mysql'


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
#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')
rs = con.query('show tables')
rs.each_hash { |h| puts h['Tables_in_limitless'] unless h['Tables_in_limitless'] == 'industries' || h['Tables_in_limitless'] == 'companies'
										next if h['Tables_in_limitless'] == 'industries' || h['Tables_in_limitless'] == 'companies'
										q = con.query("select * from #{h['Tables_in_limitless']}")
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
																			tech = con.query("UPDATE #{table} set short_ema=#{sema}, long_ema=#{lema}, macd=#{macd}, signal_line=#{signal}, histogram=#{hist} WHERE date='#{row}'") 
																			#tech0 = con.query("UPDATE #{table} set short_ema='#{sema} WHERE date='#{row}'")	
																			#tech1 = con.query("UPDATE #{table} set long_em=#{lema} WHERE date=#{row}")
																			#tech2 = con.query("UPDATE #{table} set signal_line=#{signal} WHERE date=#{row}")
																			#tech3 = con.query("UPDATE #{table} set histogram=#{hist} WHERE date=#{row}")
#																			puts "#{table} #{row}  short ema: #{sema} long ema: #{lema} macd: #{macd} signal line: #{signal} histogram: #{hist}"
																}
							}


con.close
