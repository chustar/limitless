require 'mysql'
require 'date'
$stdout = File.new('futurevol.out', 'w')
$stdout.sync = true

con = Mysql.new('localhost', 'root', '', 'limitless')
ema = con.query('select count(*) from ema_weekly_window')
emaTotal = 0;
emaUp = 0
emaDown = 0
ema.each_hash { |a|
	emaTotal = a['count(*)'].to_f
}

ema = con.query('select count(*) from ema_weekly_window where up=1')
ema.each_hash { |a|
	emaUp = a['count(*)'].to_f
}

ema = con.query('select count(*) from ema_weekly_window where up=0')
ema.each_hash { |a|
	emaDown = a['count(*)'].to_f
}
puts "#{emaTotal}"
puts "#{emaUp}"
puts "#{emaDown}"

ema_up_percent = emaUp.to_f/emaTotal * 100
ema_down_percent = emaDown.to_f/emaTotal * 100

puts "chance up: #{ema_up_percent}"
puts "chance down: #{ema_down_percent}"


volumeTotal = 0
volumeUp = 0
volumeDown = 0

vol = con.query('select count(*) from volume_weekly_window');
vol.each_hash { |v|
	volumeTotal = v['count(*)'].to_f
}

vol = con.query('select count(*) from volume_weekly_window where up=1')
vol.each_hash { |v|
	volumeUp = v['count(*)'].to_f
}

vol = con.query('select count(*) from volume_weekly_window where up=0')
vol.each_hash { |v|
	volumeDown = v['count(*)'].to_f
}

vol_up_p = volumeUp.to_f/volumeTotal * 100
vol_down_p = volumeDown.to_f/volumeTotal * 100

puts "vol percent up: #{vol_up_p}"
puts "vol percent down: #{vol_down_p}"

macdTotal = 0
macdUp = 0
macdDown = 0 

macd = con.query('select count(*) from macd_weekly_window')
macd.each_hash { |m| 
	macdTotal = m['count(*)'].to_f
}

macd = con.query('select count(*) from macd_weekly_window where up=1')
macd.each_hash { |m|
	macdUp = m['count(*)'].to_f
}

macd = con.query('select count(*) from macd_weekly_window where up=0')
macd.each_hash { |m|
	macdDown = m['count(*)'].to_f
}

macd_up_p = macdUp.to_f/macdTotal * 100
macd_down_p = macdDown.to_f/macdTotal * 100

puts "macd up: #{macd_up_p}"
puts "macd down: #{macd_down_p}"

		vol_future_up = 0
		vol_future_down = 0
		vol_future_total = 0

rs = con.query('show tables')
rs.each_hash { |h|
	if h['Tables_in_limitless'] =~ /company_.*/
		# check prediction for volume
		name = h['Tables_in_limitless'].split('_',2)
		q = con.query("select * from companies where symbol='#{name[1]}' LIMIT 1")
		avg = 0
		q.each_hash { |a|
			avg = h['avg_volume'].to_f
		}
		q = con.query("select * from #{h['Tables_in_limitless']} where date > '2011-9-28' order by date")
		unless avg.nan?
			q.each_hash { |a|
				vol_future_total += 1
				days_lookahead = 1
				volume = a['volume'].to_f
				cur_price = a['close_price']
				s = a['date'].split('-')
				high_v = ((volume.to_f - avg.to_f)/volume.to_f) * 100 
				op = a['open_price']
				cp = a['close_price']
				pp = ((cp.to_f - op.to_f)/cp.to_f) * 100


				up = 0
				if high_v > 25 && pp > 1
					while days_lookahead.to_i < 11
				    date2 = Date.new(s[0].to_i, s[1].to_i, s[2].to_i) + days_lookahead 
						theFUTURE = con.query("select * from #{h['Tables_in_limitless']} where date='#{date2}' LIMIT 1")
						theFUTURE.each_hash { |f1|
							f_close_price = f1['close_price']
							price = f1['close_price'].to_f - cur_price.to_f
							price = price.to_f/cur_price.to_f
							price *= 100 
							if price > 3
								puts "up counted current price #{cur_price} future price #{f1['close_price']}"
								vol_future_up += 1
								up = 1
							end
						}
					if up > 0
						break
					end
					days_lookahead += 1
					end
					if up <= 0 && days_lookahead >=  10
						vol_future_down += 1
						puts "down counted"
					end

				end
			}
		end #unless avg.nan?
	end #if h table company
}

puts "#{h['Tables_in_limitless']}"
puts "percent right: #{vol_future_up}"
puts "percent wrong: #{ vol_future_down}"


rs = con.query('show tables')
rs.each_hash { |h|
	if h['Tables_in_limitless'] =~ /company_.*/
			q = con.query("select * from #{h['Tables_in_limitless']} where date > '2011-9-28' order by date")
                    table = h['Tables_in_limitless']
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
                                                  con.query("INSERT INTO macd_weekly_window (date, company, histogram, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['histogram']}', '1')")                                                  up = 1 
                                                else
                                                  if days_lookahead >= 10
                                                 #  puts "NO #{date2}: #{f1['close_price']} #{date}: #{cur_price}"
                                                  # con.query("INSERT INTO macd_weekly_window (date, company, histogram, up) VALUES ('#{date}', '#{h['Tables_in_limitless']}', '#{a['histogram']}', '0')")
                                                  end
                                                end   
                                            }       
                                            if up > 0
                                              break;
                                            end   
                                            if up <= 0 && days_lookahead >= 10
                                              puts "NO #{date}: #{cur_price}"
                                       			end
                                            days_lookahead += 1
                                            end 
                                          end
                                        end
                                        }
                                }


	end
}



