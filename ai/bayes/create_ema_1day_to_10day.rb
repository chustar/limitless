# This file inserts the data into table ema22 
# ema is calculated using the short distance subtracting the long distance which is represented as MACD
# if the difference is less than .50 then the data will be logged 
require 'mysql'
require 'date'

#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')
rs = con.query('show tables')
rs.each_hash { |h| 

			puts h['Tables_in_limitless'] unless h['Tables_in_limitless'] == 'industries' || h['Tables_in_limitless'] == 'companies'
										
									
										if h['Tables_in_limitless'] =~ /company_.*/
										q = con.query("select * from #{h['Tables_in_limitless']}")
										table = h['Tables_in_limitless']
										q.each_hash { |a|
																	up = 0
																	days_lookahead = 1
																	while days_lookahead < 11
																			date = a['date']
																			# need to validate days of ema that cross up not down
																			pastDate = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) - 1
																			thePAST = con.query("select * from #{h['Tables_in_limitless']} where date='#{pastDate}' LIMIT 1")
																			thePAST.each_hash { |p|
																			if a['macd'].to_f < 0.50 && a['macd'].to_f > 0 && && aDate.parse("#{date}") < Date.parse("2011-9-28")
																				s = a['date'].split('-')
																				date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + days_lookahead 
																				cur_price = a['close_price']
																	#			puts "#{date} = #{date2}"	
																				theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
																			#puts "#{theFUTURE['close_price']}"
																				theFUTURE.each_hash { |f1|
																					price = f1['close_price'].to_f - cur_price.to_f 
																					price = price.to_f/cur_price.to_f 
																					price *= 100
																					if price > 3 
																						puts "#{price}"
																						puts "YES #{date2}: #{f1['close_price']} #{date}: #{cur_price} macd #{f1['macd']} round #{f1['macd'].to_i}"
																						con.query("INSERT INTO ema5 (date, company, macd, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['macd']}', '1')")
																						up = 1
																					else
																							if days_lookahead >= 10
																						puts "NO #{date2}: #{f1['close_price']} #{date}: #{cur_price} macd #{f1['macd']} round #{f1['macd'].to_i}"
																						con.query("INSERT INTO ema5 (date, company, macd, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['macd']}', '0')")
																							up = 0
																							end
																					end
																			}
																			end
																			}
																	if up > 0
																		up = 0
																		break
																	end
																	 
																	days_lookahead = days_lookahead + 1
																	end
																			# tech = con.query("UPDATE #{table} set short_ema=#{sema}, long_ema=#{lema}, macd=#{macd}, signal_line=#{signal}, histogram=#{hist} WHERE date='#{row}'") 
#																			# puts "#{table} #{row}  short ema: #{sema} long ema: #{lema} macd: #{macd} signal line: #{signal} histogram: #{hist}"
																}
										end
							}


con.close
