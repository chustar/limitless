# This file inserts the historgram data into table volume 
require 'mysql'
require 'date'

#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')
rs = con.query('show tables')
rs.each_hash { |h| 
                        
										unless h['Tables_in_limitless'] == 'industries' || h['Tables_in_limitless'] == 'companies' || h['Tables_in_limitless'] == 'ema22' || h['Tables_in_limitless'] == 'volume5050' || h['Tables_in_limitless'] == 'macd22'
										#if h['Tables_in_limitless'] == 'company_A'
                    q = con.query("select * from #{h['Tables_in_limitless']}")
                    table = h['Tables_in_limitless']
										name = h['Tables_in_limitless'].split('_',2)
										volume = 0
										count = 0
										avg = 0
										puts "#{h['Tables_in_limitless']}"
										q.each_hash { |a| 
																			date = a['date']
                                      s = a['date'].split('-')
                                      date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + 44 
                                        
																			cur_price = a['close_price']
																			if a['histogram'].to_f < 0.50 && a['histogram'].to_f > 0 && Date.parse("#{date}") < Date.parse("2011-9-28")
																				# if volumen is higher than 50% and closing price is higher than 25%
																					theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
                                    		  theFUTURE.each_hash { |f1|
                                    		      price = f1['close_price'].to_f - cur_price.to_f 
                                    		      price = price.to_f/cur_price.to_f 
                                    		      price *= 100 
                                    		      if price > 3 
																								#puts "#{price}"
                                    		        #puts "YES #{date2}: #{f1['close_price']} #{date}: #{cur_price}"
                                    		        con.query("INSERT INTO macd22 (date, company, histogram, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['histogram']}', '1')")
                                    		      else
                                    		        #puts "NO #{date2}: #{f1['close_price']} #{date}: #{cur_price}"
                                    		        con.query("INSERT INTO macd22 (date, company, histogram, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['histogram']}', '0')")
                                    		      end 
																					}
																			end
                                }
                    end 
              }   

con.close
