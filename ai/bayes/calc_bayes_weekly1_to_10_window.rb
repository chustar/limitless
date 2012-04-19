require 'mysql'
require 'date'

con = Mysql.new('localhost', 'root', '', 'limitless')
ema = con.query('select count(*) from ema22')
emaTotal = 0;
emaUp = 0
emaDown = 0
ema.each_hash { |a|
	emaTotal = a['count(*)'].to_f
}

ema = con.query('select count(*) from ema22 where up=1')
ema.each_hash { |a|
	emaUp = a['count(*)'].to_f
}

ema = con.query('select count(*) from ema22 where up=0')
ema.each_hash { |a|
	emaDown = a['count(*)'].to_f
}
puts "#{emaTotal}"
puts "#{emaUp}"
puts "#{emaDown}"

ema_up_percent = emaUp.to_f/emaTotal * 100
ema_down_percent = emaDown.to_f/emaTotal * 100

puts "#{ema_up_percent}"
puts "#{ema_down_percent}"




