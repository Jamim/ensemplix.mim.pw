from pyramid.config import Configurator
from mako.template import Template
from pyramid.response import Response
from time import time
from math import sqrt

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

def get_distance(coords0, coords1):
	return sqrt((coords0[0] - coords1[0])**2 + (coords0[1] - coords1[1])**2 + (coords0[2] - coords1[2])**2)

warps_expire_delay = 1800 # полчаса
warps_expire_time = 0
nearest_warps = {}

def update_warps():
	global warps

	cursor = sql_connection.cursor()
	cursor.execute('SELECT x, y, z, warp FROM warps WHERE server_id = 3;')
	warps = cursor.fetchall()
	cursor.close()

	nearest_warps.clear()
	warps_expire_time = time() + warps_expire_delay

def get_warp(coords):
	if warps_expire_time < time():
		update_warps()

	if coords in nearest_warps:
		return nearest_warps[coords]

	nearest_warp = warps[0]
	min_distance = get_distance(coords, nearest_warp)
	for warp in warps[1:]:
		distance = get_distance(coords, warp)
		if distance < min_distance:
			min_distance = distance
			nearest_warp = warp

	warp = {'warp': nearest_warp, 'distance': min_distance}
	nearest_warps[coords] = warp

	return warp

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

	prepared_history = []
	for event in history:
		warp = get_warp((event[9:12]))
		prepared_history.append((warp,) + event)

	template = Template(filename=app_dir + 'templates/shops_history.mako')
	result = template.render(start_time=start_time, history=prepared_history, get_termination=get_termination)
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
