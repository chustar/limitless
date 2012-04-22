# This file inserts the historgram data into table volume 
require 'mysql'
require 'date'
$stdout = File.new('macd_cron.out', 'a') 
$stdout.sync = true 
#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')

startDate = Time.new.to_date - 14
puts "Analysis for #{Time.new.to_date}"

rs = con.query('show tables')
rs.each_hash { |h| 
                        
										if h['Tables_in_limitless'] =~ /company_.*/
                    q = con.query("select * from #{h['Tables_in_limitless']} where date = '#{startDate.year}-#{startDate.month}-#{startDate.day}' order by date")
                    table = h['Tables_in_limitless']
										puts "#{h['Tables_in_limitless']} #{startDate}"
										name = h['Tables_in_limitless'].split('_',2)
										volume = 0
										count = 0
										avg = 0
										puts "#{h['Tables_in_limitless']}"
										q.each_hash { |a|
																			d_date = ''
																			d_histo = 0.0
												 
																			up = 0
																			days_lookahead = 1
																			date = a['date']
                                      s = a['date'].split('-')
                                      pastDate = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) -1
																			thePAST = con.query("select * from #{h['Tables_in_limitless']} where date='#{pastDate}' LIMIT 1")
																			thePAST.each_hash { |p|
																			unless a['histogram'].empty? || p['histogram'].empty?  
																				cur_price = a['close_price']
																				if a['histogram'].to_f > 0 && p['histogram'].to_f < 0 && Date.parse("#{date}") < Date.parse("2011-9-28")
                                      		while days_lookahead < 11	
																					date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + days_lookahead 
																					puts "#{date} #{date2} #{days_lookahead}"
																						# if volumen is higher than 50% and closing price is higher than 25%
																						theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
                                    			  theFUTURE.each_hash { |f1|
                                    			      price = f1['close_price'].to_f - cur_price.to_f 
                                    			      price = price.to_f/cur_price.to_f 
                                    			      price *= 100 
                                    			      if price > 3 
																									#puts "#{price}"
                                    			        puts "YES #{date2}: #{f1['close_price']} #{date}: #{cur_price}"
                                    			        #con.query("INSERT INTO macd_weekly_window (date, company, histogram, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['histogram']}', '1')")
																									up = 1
                                    			      end 
																						}
																						if up > 0
																							break;
																						end
																						if up <= 0 && days_lookahead >= 10
                                    			    puts "NO #{date}: #{cur_price}"
																							#con.query("INSERT INTO macd_weekly_window (date, company, histogram, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['histogram']}', '0')    ")                                                
																						end
																						days_lookahead += 1
																						end
																				  end
																				end
																				}
                                }
                    end 
              }   

con.close
