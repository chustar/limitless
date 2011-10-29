import urllib
import json
import datetime
import pymysql

"""	f = open('company.csv', 'r')
	companies = f.read().split(', ')
	for  company in companies:
		print company
		if company != '\n':
			data =  yahoo.get_historical_prices(company,startdate,enddate)
			for d in data:
				print d
	f.close()
"""

def get_industries(sector):
	"""
	Gets the companies in a certain industry
	sector is a string containing the sector name
	"""
	conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='')
	cur = conn.cursor()
	file = open("db_scripts/create_database.sql");
	cur.execute(file.read())
	
	url = 'http://query.yahooapis.com/v1/public/yql?q=' + \
		urllib.quote('select * from yahoo.finance.sectors where name = "%(name)s"' %{"name": sector}) + \
		'&env=store://datatables.org/alltableswithkeys&format=json'
	res = urllib.urlopen(url).readlines()
	res = json.loads(res[0])
		
	file = open("db_scripts/create_industries.sql");
	cur.execute(file.read())
	file.close()
	for industry in res['query']['results']['sector']['industry']:
		print industry['id'].__class__
		print int(industry['id']).__class__
		industry['id'] = int(industry['id'])
		cur.execute('INSERT INTO industries (yahoo_id, name) VALUES(%(num)i, "%(name)s")' %{'num': industry['id'], 'name': industry['name']})
		get_companies(industry['id'], cur)
	
	cur.close()
	conn.close()


def	get_companies(industry, cur):
	url = 'http://query.yahooapis.com/v1/public/yql?q=' + \
		urllib.quote('select * from yahoo.finance.industry where id = "%(id)i"' %{"id": industry}) + \
		'&env=store://datatables.org/alltableswithkeys&format=json'
	res = urllib.urlopen(url).readlines()
	res = json.loads(res[0])
	
	startdate = '1900-01-01'
	enddate = datetime.datetime.now()
	
	file = open("db_scripts/create_companies.sql");
	cur.execute(file.read())
	file.close()
	for company in res['query']['results']['industry']['company']:
		print company['name']
		cur.execute('INSERT INTO companies (name, symbol) VALUES (%s, %s)', (company['name'], company['symbol']))
		get_historical_prices(company['symbol'], cur, startdate, str(enddate)[:10])
	

#TODO: I think i'm requesting too much data from YQL. That's the only thing that would explain why i get None results. Will switch back to old URL
def get_historical_prices(symbol, cur, startdate, enddate):
	"""
	Get historical prices for the given ticker symbol.
	Date format is 'YYYYMMDD'
	Returns a nested list.
	"""
	url = 'http://query.yahooapis.com/v1/public/yql?q=' + \
		urllib.quote('select * from yahoo.finance.historicaldata where symbol = "%s" and startDate = "%s" and endDate = "%s"' %(symbol, startdate, enddate)) + \
		'&env=store://datatables.org/alltableswithkeys&format=json'
	res = urllib.urlopen(url).readlines()
	res = json.loads(res[0])
	
	file = open("db_scripts/create_company.template");
	cur.execute(file.read() %{'symbol': symbol})
	file.close()
	if res['query']['results'] is not None:
		for stock in res['query']['results']['quote']:
			print stock
			cur.execute('INSERT INTO company_%s (date, volume, high_price, low_price, open_price, close_price, close_adjusted, price_change) VALUES ("%s", "%s", %f, %f, %f, %f, %f, %f )' %(symbol, stock['Date'], float(stock['Volume']), float(stock['High']), float(stock['Low']), float(stock['Open']), float(stock['Close']), float(stock['Adj_Close']), float(stock['Open']) - float(stock['Close'])))
		


if __name__ == '__main__':
	get_industries("Technology")
