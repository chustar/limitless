require 'mysql'
require 'date'
$stdout = File.new('accuracyEMA.out', 'w')
$stdout.sync = true

emaUp = 0
emaDown = 0
con = Mysql.new('localhost', 'root', '', 'limitless')

rs = con.query('show tables')
rs.each_hash { |h| 

			puts h['Tables_in_limitless'] unless h['Tables_in_limitless'] == 'industries' || h['Tables_in_limitless'] == 'companies'
										
									
										if h['Tables_in_limitless'] =~ /company_.*/
										q = con.query("select * from #{h['Tables_in_limitless']} where date > '2011-9-28' order by date")
										table = h['Tables_in_limitless']
										q.each_hash { |a|
																	up = 0
																	days_lookahead = 1
																			date = a['date']
																			# need to validate days of ema that cross up not down
																			s = a['date'].split('-')
																			pastDate = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) - 1
																			thePAST = con.query("select * from #{h['Tables_in_limitless']} where date='#{pastDate}' LIMIT 1")
																			thePAST.each_hash { |p|
																			unless p['macd'].empty? && a['macd'].empty?
																				if a['macd'].to_f > 0 && p['macd'].to_f < 0
																					puts "#{a['macd']} past: #{p['macd']}"
																					while days_lookahead < 11
																						puts "#{days_lookahead}"
																						date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + days_lookahead 
																						cur_price = a['close_price']
																		#				puts "#{date} = #{date2}"	
																						theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
																					#puts "#{theFUTURE['close_price']}"
																						theFUTURE.each_hash { |f1|
																							price = f1['close_price'].to_f - cur_price.to_f 
																							price = price.to_f/cur_price.to_f 
																							price *= 100
																							if price > 3 
																								emaUp += 1
																								puts "YES #{date2}: #{f1['close_price']} #{date}: #{cur_price} macd #{f1['macd']} round #{f1['macd'].to_i}"
																								up = 1
																							end
																						}
																						if up > 0
																								break
																						end
																						if up <= 0 && days_lookahead >= 10
																								puts "NO #{date}: #{cur_price}"
																								emaDown += 1
																						end
																						days_lookahead = days_lookahead + 1
																						end
																				end
																			end
																			}
																			# tech = con.query("UPDATE #{table} set short_ema=#{sema}, long_ema=#{lema}, macd=#{macd}, signal_line=#{signal}, histogram=#{hist} WHERE date='#{row}'") 
#																			# puts "#{table} #{row}  short ema: #{sema} long ema: #{lema} macd: #{macd} signal line: #{signal} histogram: #{hist}"
																}
										end
							}
puts "Up : #{emaUp} Percent Up #{emaUp.to_f/(emaUp.to_f + emaDown.to_f)} Down: #{emaDown} Percent Down: #{emaDown.to_f/(emaDown.to_f + emaUp.to_f)}"
