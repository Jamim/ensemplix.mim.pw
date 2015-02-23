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

def update_warps():
	global warps, nearest_warps

	cursor = sql_connection.cursor()
	warps, nearest_warps = {}, {}
	for server_id in servers_ids:
		cursor.execute('SELECT x, y, z, warp FROM warps WHERE server_id = %s;', (server_id,))
		warps[server_id] = cursor.fetchall()
		nearest_warps[server_id] = {}
	cursor.close()

	warps_expire_time = time() + warps_expire_delay

def get_warp(server_id, coords):
	if warps_expire_time < time():
		update_warps()

	if coords in nearest_warps[server_id]:
		return nearest_warps[server_id][coords]

	server_warps = warps[server_id]
	nearest_warp = server_warps[0]
	min_distance = get_distance(coords, nearest_warp)
	for warp in server_warps[1:]:
		distance = get_distance(coords, warp)
		if distance < min_distance:
			min_distance = distance
			nearest_warp = warp

	warp = {'warp': nearest_warp, 'distance': min_distance}
	nearest_warps[server_id][coords] = warp

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

	server = 'server' in request.matchdict and request.matchdict['server'] or False
	server_id = server and servers[server]

	sql = sql.replace('[server]', not server and ', servers.name' or '').replace('[JOIN]', not server and '\tJOIN servers ON servers.id = server_id\n' or '').replace('[WHERE]', server and 'WHERE server_id=%(server_id)s ' or '')
	request_params = {'server_id': server_id}

	cursor = sql_connection.cursor()
	cursor.execute(sql, request_params)
	history = cursor.fetchall()
	cursor.close()

	prepared_history = []
	for event in history:
		warp = get_warp(3, event[9:12])
		prepared_history.append((warp,) + event)

	template = Template(filename=app_dir + 'templates/shops_history.mako')
	result = template.render(start_time=start_time, server=server, history=prepared_history, get_termination=get_termination)
	response = Response(result)

	return response

day  = 3600 * 24
week = day * 7

class ItemStats:
	def __init__(self, where_to_buy, where_to_sell, daily, weekly):
		self.where_to_buy  = where_to_buy
		self.where_to_sell = where_to_sell
		self.daily  = daily
		self.weekly = weekly

def get_item_stats_data(cursor, server_id, item_id, stats_sql, where_to_buy_sql, where_to_sell_sql, start_time):
	day_ago  = start_time - day
	week_ago = start_time - week

	request_params = {'server_id': server_id, 'item_id': item_id, 'created': week_ago}

	cursor.execute(where_to_buy_sql, request_params)
	where_to_buy = cursor.fetchall()
	cursor.execute(where_to_sell_sql, request_params)
	where_to_sell = cursor.fetchall()

	cursor.execute(stats_sql, request_params)
	weekly_stats = cursor.fetchall()
	request_params['created'] = day_ago
	cursor.execute(stats_sql, request_params)
	daily_stats = cursor.fetchall()


	prepared_where_to_buy = []
	for shop in where_to_buy:
		warp = get_warp(server_id, shop[-3:])
		prepared_where_to_buy.append((warp,) + shop)

	prepared_where_to_sell = []
	for shop in where_to_sell:
		warp = get_warp(server_id, shop[-3:])
		prepared_where_to_sell.append((warp,) + shop)

	return ItemStats(prepared_where_to_buy, prepared_where_to_sell, daily_stats, weekly_stats)


def item_view(request):
	start_time = time()
	shops_sql = load_sql('item_shops.sql')
	stats_sql = load_sql('item_stats.sql')

	where_to_buy_sql  = shops_sql.replace('[NOT]', 'NOT ').replace('[DESC]', '')
	where_to_sell_sql = shops_sql.replace('[NOT]', '')    .replace('[DESC]', ' DESC')

	item_id = int(request.matchdict['item_id'])
	server = 'server' in request.matchdict and request.matchdict['server'] or False
	server_id = server and servers[server]

	cursor = sql_connection.cursor()
	cursor.execute("SELECT * FROM items WHERE id = %s;", (item_id,))
	item_info = cursor.fetchone()

	item_stats_by_server = {}
	template = Template(filename=app_dir + 'templates/item.mako')

	if server:
		item_stats = get_item_stats_data(cursor, server_id, item_id, stats_sql, where_to_buy_sql, where_to_sell_sql, start_time)
		item_stats_by_server[server] = item_stats
	else:
		for server_id in servers_ids:
			item_stats = get_item_stats_data(cursor, server_id, item_id, stats_sql, where_to_buy_sql, where_to_sell_sql, start_time)
			item_stats_by_server[servers[server_id]] = item_stats

	cursor.close()

	result = template.render(start_time=start_time, item_info=item_info, item_stats=item_stats_by_server, get_termination=get_termination)
	response = Response(result)

	return response

def items_view(request):
	start_time = time()
	week_ago = start_time - week
	sql = load_sql('items_stats.sql')
	request_params = {'created': week_ago}

	cursor = sql_connection.cursor()
	cursor.execute(sql, request_params)
	items = cursor.fetchall()

	template = Template(filename=app_dir + 'templates/items.mako')
	result = template.render(start_time=start_time, items=items)
	response = Response(result)

	return response

def get_servers():
	global servers, servers_ids

	cursor = sql_connection.cursor()
	cursor.execute("SELECT id, name FROM servers WHERE name != 'Carnage';")
	servers, servers_ids = {}, []
	for server_id, server_name in cursor.fetchall():
		servers[server_id]   = server_name
		servers[server_name] = server_id
		servers_ids.append(server_id)
	cursor.close()

def main(global_config, **settings):
	global app_dir, sql_connection
	app_dir = settings['buildout_dir']

	with open(app_dir + 'sql_password') as input:
		password = input.read().strip()

	sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))
	get_servers()


	config = Configurator(settings=settings)

	config.add_route('shops_history_last', '/shops/history/last')
	config.add_route('server_shops_history_last', '/{server}/shops/history/last')
	config.add_view(shops_history_last, route_name='shops_history_last')
	config.add_view(shops_history_last, route_name='server_shops_history_last')

	config.add_route('item', '/item/{item_id}')
	config.add_route('server_item', '/{server}/item/{item_id}')
	config.add_view(item_view, route_name='item')
	config.add_view(item_view, route_name='server_item')

	config.add_route('items', '/items')
	config.add_view(items_view, route_name='items')

	return config.make_wsgi_app()
