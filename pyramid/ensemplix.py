from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from mako.template import Template
from pyramid.response import Response
from time import time
from sys import argv

import psycopg2
import json


ip, port, password = argv[1:]
sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))


def load_file(filename):
	with open(filename, encoding='utf-8') as input:
		data = input.read()
	return data

def load_sql(filename):
	return load_file('sql/' + filename)

def shops_history_last(request):
	start_time = time()
	sql = load_sql('shops_history_last.sql')

	cursor = sql_connection.cursor()
	cursor.execute(sql)
	history = cursor.fetchall()
	cursor.close()

	template = Template(filename='templates/shops_history.mako')
	result = template.render(start_time=start_time, history=history)
	response = Response(result)

	return response

if __name__ == '__main__':
	config = Configurator()

	config.add_route('shops_history_last', '/shops/history/last')
	config.add_view(shops_history_last, route_name='shops_history_last')

	app = config.make_wsgi_app()
	server = make_server(ip, int(port), app)
	server.serve_forever()
