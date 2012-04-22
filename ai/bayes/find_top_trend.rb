# This file inserts the data into table ema22 
# ema is calculated using the short distance subtracting the long distance which is represented as MACD
# if the difference is less than .50 then the data will be logged 
require 'mysql'
require 'date'
$stdout = File.new('top_trend.out', 'a')
$stdout.sync = true
#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')


class Com
	attr_accessor :name, :percent
	def initialize(name, percent)
		@name = name
		@percent = percent
	end
end

top = []
top << Com.new("minh", 0)
top << Com.new("minh", 0)
top << Com.new("minh", 0)
top << Com.new("minh", 0)
top << Com.new("minh", 0)

#only check date that's 14 days behind
startDate = Time.new.to_date 
startDate2 = Time.new.to_date - 1
puts "Analysis for #{startDate}"
pema = 0
pmacd = 0

ema_v = 0
macd_v = 0
v_v = 0
p = con.query("select * from bayes_prediction")
p.each_hash { |a| 
	ema_v = a['ema_up']
	macd_v = a['macd_up']
	v_v = a['v_up']
}

puts "#{v_v} #{macd_v} #{ema_v}"

rs = con.query('show tables')
rs.each_hash { |h| 

																			
	if h['Tables_in_limitless'] =~ /^company_.*/
		
		q = con.query("select * from #{h['Tables_in_limitless']} where date = '#{startDate2.year}-#{startDate2.month}-#{startDate2.day}'")
		q.each_hash { |a|
			 pema = a['macd'].to_f
			 pmacd = a['histogram'].to_f
		}	
		
	
		q = con.query("select * from #{h['Tables_in_limitless']} where date = '#{startDate.year}-#{startDate.month}-#{startDate.day}'")
		q.each_hash { |a|
		  name = h['Tables_in_limitless'].split('_',2)
			compavg = con.query("select * from companies where symbol='#{name[1]}' LIMIT 1") 
      avg = 0;
      compavg.each_hash { |v| 
       avg = v['avg_volume'].to_f
      }  

		  upCount = 0
			if pema.to_f < 0 && a['macd'].to_f > 0
				upCount += ema_v.to_f	
			end
			if pmacd.to_f < 0 && a['histogram'].to_f > 0
				upCount += macd_v.to_f
			end
			volume = a['volume'].to_f
			op = a['open_price']
			cp = a['close_price']
			pp = ((cp.to_f - op.to_f)/cp.to_f) * 100
			high_v = ((volume.to_f - avg.to_f)/volume.to_f) * 100 	
			unless avg.nan?
				if high_v > 25 && pp > 1 
			  	upCount += v_v.to_f	
				end
			end

			count = 0
			while count.to_i < 5
				if top[count].percent.to_f < upCount.to_f 
					puts "#{h['Tables_in_limitless']} at #{count}"
					top[count].name = h['Tables_in_limitless']
					top[count].percent = upCount
					break
				end
			count += 1
			end
		}			
	end
	}

count = 0
puts "Top Trending Company*"
puts "Rank Sym Percent"
while count.to_i < 5
	puts "#{count} #{top[count].name} #{top[count].percent}"
	count += 1
end

con.close
