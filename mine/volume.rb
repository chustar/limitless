# This file inserts the high volumes data  into table volume 
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
										q.each_hash { |a| 
																			date = a['date']
                                      s = a['date'].split('-')
                                      date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + 22
                                        
																			cur_price = a['close_price']
                                      volume = a['volume'].to_f
																			compavg = con.query("select * from companies where symbol='#{name[1]}' LIMIT 1") 
																			avg = 0;
																			compavg.each_hash { |v|
																				avg = v['avg_volume'].to_f
																			}	
																			puts "#{avg}"
																			unless avg.nan?	
																				high_v = ((volume.to_f - avg.to_f)/volume.to_f) * 100
																				op = a['open_price']
																				cp = a['close_price']
																				pp = ((cp.to_f - op.to_f)/cp.to_f) * 100
																				# if volumen is higher than 50% and closing price is higher than 25%
																				if high_v > 50 && pp > 25
																					theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
                                    		  theFUTURE.each_hash { |f1|
                                    		      price = f1['close_price'].to_f - cur_price.to_f 
                                    		      price = price.to_f/cur_price.to_f 
                                    		      price *= 100 
                                    		      if price > 5 
                                    		        puts "#{price}"
                                    		        puts "YES #{date2}: #{f1['close_price']} #{date}: #{cur_price}"
                                    		        con.query("INSERT INTO volume5050 (date, company, volume, open_price, close_price, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{volume}','#{op}', '#{cp}', '1')")
                                    		      else
                                    		        puts "NO #{date2}: #{f1['close_price']} #{date}: #{cur_price}"
                                    		        con.query("INSERT INTO volume5050 (date, company, volume, open_price, close_price, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{volume}','#{op}', '#{cp}', '0')")
                                    		      end 
																					}
																				end
																			end
                                }
                    end 
              }   

con.close
