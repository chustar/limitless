from string import upper
import datetime
import os
import pymysql

def write_to_file(filename, data, name):
	f = open(filename, 'w')
	f.write(
"""@RELATION %s 
@ATTRIBUTE volume           NUMERIC
@ATTRIBUTE high_price       NUMERIC
@ATTRIBUTE low_price        NUMERIC
@ATTRIBUTE open_price       NUMERIC
@ATTRIBUTE close_price      NUMERIC
@ATTRIBUTE close_adjusted   NUMERIC
@ATTRIBUTE price_change     NUMERIC
@ATTRIBUTE short_ema        NUMERIC
@ATTRIBUTE long_ema         NUMERIC
@ATTRIBUTE macd             NUMERIC
@ATTRIBUTE signal_line      NUMERIC
@ATTRIBUTE histogram        NUMERIC
@ATTRIBUTE target_price     NUMERIC

@DATA
""" %(name))

	for line in data:
		f.write(','.join(str(x) for x in line[0]))
		f.write(',')
		f.write(str(line[1]))
		f.write('\n')
	f.close()


def get_company(symbol):
	print 'Running ' + symbol + '...'
	conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='limitless')
	cur = conn.cursor()
	cur.execute('SELECT date, volume, high_price, low_price, open_price, close_price, close_adjusted, price_change, short_ema, long_ema, macd, signal_line, histogram FROM company_%(symbol)s ORDER BY date' %{'symbol': upper(symbol) })

	days = datetime.timedelta(22)
	train_data = []
	test_data = []
	dates = []
	results = cur.fetchall()
	for company in results:
		test_data.append([company[1:], company[2]])
		dates.append(company[0] + days)
		for search in results:
			if (search[0]) == (company[0] + days):
				train_data.append([company[1:], search[2]])
				break

	filename = "arff/" + symbol + ".train.arff"
	filename2 = "arff/" + symbol + ".test.arff"
	write_to_file(filename, train_data, symbol)
	write_to_file(filename2, test_data, symbol)
	
	execs = '/usr/bin/jython weka.py arff/' + symbol + '.train.arff arff/' + symbol + '.test.arff'
	os.system(execs);
	return dates;

if __name__ == '__main__':
	for path in ['arff', 'models', 'predictions']
		if not os.path.isdir(path):
			   os.makedirs(path)

	newpath = 'C:\Program Files\alex'; if not os.path.exists(newpath): os.makedirs(newpath)
	conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='limitless')
	cur = conn.cursor()
	cur.execute('SELECT symbol FROM companies WHERE avg_volume IS NOT NULL')
	
	results = cur.fetchall()
	for symbol in results:
		dates = get_company(symbol[0])	
	
		print "Saving...\n"
		cur.execute('DROP TABLE IF EXISTS `weka_prediction_company_%s`' %(symbol[0]))
		cur.execute('CREATE TABLE IF NOT EXISTS `weka_prediction_company_%s` (`date` date NOT NULL, `open_price` float DEFAULT NULL, `close_price` float DEFAULT NULL)' %(symbol[0]))

		file = open("predictions/%s" %(symbol[0]))
		counter = 0;
		for line in file:
			sql = "INSERT INTO `weka_prediction_company_%s`(date, open_price, close_price) VALUES ('%s', 0, %f)" %((symbol[0], dates[counter], float(line)))
			cur.execute(sql) 
			counter = counter + 1
		file.close()
