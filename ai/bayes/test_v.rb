require 'mysql'
require 'date'

$stdout = File.new('accuracyVol.out', 'w')
$stdout.sync = true 



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
