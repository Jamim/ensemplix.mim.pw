from pyramid.config import Configurator
from mako.template import Template
from pyramid.response import Response
from time import time

import psycopg2


def get_termination(count, variants):
	count = count % 100
	if 4 < count < 21:
		return variants[2]

	count = count % 10
	if count == 1:
		return variants[0]
	if 1 < count < 4: return variants[1]

	return variants[2]

def load_file(filename):
	with open(app_dir + filename, encoding='utf-8') as input:
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

	template = Template(filename=app_dir + 'templates/shops_history.mako')
	result = template.render(start_time=start_time, history=history, get_termination=get_termination)
	response = Response(result)

	return response

def main(global_config, **settings):
	global app_dir, sql_connection
	app_dir = settings['buildout_dir']

	with open(app_dir + 'sql_password') as input:
		password = input.read().strip()

	sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))


	config = Configurator(settings=settings)
	config.add_route('shops_history_last', '/shops/history/last')
	config.add_view(shops_history_last, route_name='shops_history_last')

	return config.make_wsgi_app()
