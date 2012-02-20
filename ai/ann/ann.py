import datetime
import pymysql
from nnlib import NN

def get_company(symbol):
	conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='limitless')
	cur = conn.cursor()
	cur.execute('SELECT date, volume, high_price, low_price, open_price, close_price, close_adjusted, price_change, short_ema, long_ema, macd, signal_line, histogram FROM company_%(symbol)s' %{'symbol': symbol })

	days = datetime.timedelta(22)
	inputs = []
	results = cur.fetchall()
	for company in results:
		for search in results:
			if (search[0]) == (company[0] + days):
				inputs.append([list(company[1:]), [search[2]]])
		#		break
		#print str(company[0]) + " : " + str(company[0] + days)
	
	print "START TRAINING"
	n = NN(12, 12, 1) 
	n.train(inputs, 2)
	n.weights()
	n.test(inputs)

if __name__ == '__main__':
	get_company('aapl')
	# Teach network XOR function
	pat = [
			[[0,0], [0]],
			[[0,1], [1]],
			[[1,0], [1]],
			[[1,1], [0]]
			]

	# create a network with two input, two hidden, and one output nodes
	n = NN(2, 2, 1)
	# train it with some patterns
	n.train(pat)
	# test it
	n.test(pat)
