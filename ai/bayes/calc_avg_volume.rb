# This file inserts the average volume into companies table
require 'mysql'
require 'date'

#my = Mysql.new(hostname, username, password, databasename)
con = Mysql.new('localhost', 'root', '', 'limitless')
rs = con.query('show tables')
rs.each_hash { |h| 
                        
                    if h['Tables_in_limitless'] =~ /company_.*/
                    q = con.query("select * from #{h['Tables_in_limitless']}")
                    table = h['Tables_in_limitless']
										name = h['Tables_in_limitless'].split('_',2)
										volume = 0
										count = 0
										avg = 0;
										q.each_hash { |a| 
																			count += 1
                       								volume = volume.to_f + a['volume'].to_f
                                }
										avg = volume.to_f/count.to_f
                   	puts h['Tables_in_limitless']
                    puts "#{name[1]}"
										puts "#{avg.to_f}"
										
										con.query("UPDATE companies SET avg_volume=#{avg.to_f} where symbol='#{name[1]}'") unless avg.nan?; 
                    end 
              }   

con.close
