import urllib
import json
import datetime
import pymysql

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
		if len(industry) == 2:
			industry['id'] = int(industry['id'])
			industry['name'] = industry['name'].encode('ascii', errors='ignore')
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
		if len(company) == 2:
			company['name'] = company['name'].encode('ascii', errors='ignore')
			print company['name']
			company['symbol'] = company['symbol'].replace('.', '_')
			cur.execute('INSERT INTO companies (name, symbol) VALUES (%s, %s)', (company['name'], company['symbol']))
			get_historical_prices(company['symbol'], cur, startdate.replace('-', ''), str(enddate)[:10].replace('-', ''))
	

#TODO: I think i'm requesting too much data from YQL. That's the only thing that would explain why i get None results. Will switch back to old URL
def get_historical_prices(symbol, cur, start_date, end_date):
	"""
	Get historical prices for the given ticker symbol.
	Date format is 'YYYYMMDD'
	Returns a nested list.
	"""
	url = 'http://ichart.yahoo.com/table.csv?s=%s&' % symbol + \
		'd=%s&' % str(int(end_date[4:6]) - 1) + \
		'e=%s&' % str(int(end_date[6:8])) + \
		'f=%s&' % str(int(end_date[0:4])) + \
		'g=d&' + \
		'a=%s&' % str(int(start_date[4:6]) - 1) + \
		'b=%s&' % str(int(start_date[6:8])) + \
		'c=%s&' % str(int(start_date[0:4])) + \
		'ignore=.csv'
		
	days = urllib.urlopen(url).readlines()
	data = [day[:-2].split(',') for day in days]
	
	file = open("db_scripts/create_company.template.sql");
	cur.execute(file.read() %{'symbol': symbol})
	file.close()

	for stock in data[1:]:
		if len(stock) == 7:
			cur.execute('INSERT INTO company_%s (date, volume, high_price, low_price, open_price, close_price, close_adjusted, price_change) VALUES ("%s", "%s", %f, %f, %f, %f, %f, %f )' %(symbol, stock[0], float(stock[5]), float(stock[2]), float(stock[3]), float(stock[1]), float(stock[4]), float(stock[6]), float(stock[1]) - float(stock[4])))
		
		
if __name__ == '__main__':
	get_industries("Technology")
