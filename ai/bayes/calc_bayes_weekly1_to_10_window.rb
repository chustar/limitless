require 'mysql'
require 'date'
$stdout = File.new('bayes_weekly_prediction.out', 'w')
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


jk = con.query('create TABLE IF NOT EXISTS bayes_prediction (ema_total float, ema_up float, ema_down float, macd_total float, macd_up float, macd_down float, v_total float, v_up float, v_down float);')
jk = con.query('truncate ema_weekly_window')
q = con.query("insert into bayes_prediction (ema_total, ema_up, ema_down, macd_total, macd_up, macd_down, v_total, v_up, v_down) VALUES ('#{emaUp.to_f + emaDown.to_f}', '#{(emaUp.to_f/(emaUp.to_f+emaDown.to_f))*100}', '#{(emaDown.to_f/(emaUp.to_f+emaDown.to_f))*100}', '#{macdUp + macdDown}',  '#{(macdUp.to_f/(macdUp.to_f+macdDown.to_f))*100}', '#{(macdDown.to_f/(macdUp.to_f + macdDown.to_f))*100}', '#{volumeUp + volumeDown}', '#{(volumeUp.to_f/(volumeUp.to_f+volumeDown.to_f))*100}', '#{(volumeDown.to_f/(volumeUp.to_f+volumeDown.to_f))*100}')")






 
