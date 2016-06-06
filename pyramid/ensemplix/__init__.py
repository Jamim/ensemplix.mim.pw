from pyramid.config import Configurator
from pyramid.httpexceptions import HTTPNotFound
from pyramid.response import Response

from mako.template import Template
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

warps_expire_delay = 1800 # полчаса
warps_expire_time = 0

class Warp:
	def __init__(self, x, y, z, title):
		self.x = x
		self.y = y
		self.z = z
		self.title = title

	def get_distance(self, x, y, z):
		return sqrt((self.x - x)**2 + (self.y - y)**2 + (self.z - z)**2)

	def set_distance(self, distance):
		self.distance = distance

	def clone(self, distance):
		warp = Warp(self.x, self.y, self.z, self.title)
		warp.set_distance(distance)
		return warp

def update_warps():
	global warps, nearest_warps

	cursor = sql_connection.cursor()
	warps, nearest_warps = {}, {}
	for server_id in servers_ids:
		cursor.execute('SELECT x, y, z, warp FROM warps WHERE server_id = %s;', (server_id,))

		server = servers[server_id]
		server_warps = [Warp(*warp) for warp in cursor.fetchall()]
		empty = {}

		warps[server_id] = server_warps
		warps[server]    = server_warps

		nearest_warps[server_id] = empty
		nearest_warps[server]    = empty

	cursor.close()

	warps_expire_time = time() + warps_expire_delay

def get_warp(server, coords):
	if warps_expire_time < time():
		update_warps()

	if coords in nearest_warps[server]:
		return nearest_warps[server][coords]

	server_warps = warps[server]
	if server_warps:
		nearest_warp = server_warps[0]
		min_distance = nearest_warp.get_distance(*coords)
		for warp in server_warps[1:]:
			distance = warp.get_distance(*coords)
			if distance < min_distance:
				min_distance = distance
				nearest_warp = warp

		warp = nearest_warp.clone(min_distance)
		nearest_warps[server][coords] = warp

		return warp

class Deal:
	def __init__(self, server, deal):
		coords = deal[11:14]

		self.id        = deal[0]
		self.time      = deal[1]
		self.operation = deal[2]
		self.client    = deal[3]
		self.owner     = deal[4]
		self.item      = Item(*deal[5:9])
		self.amount    = deal[9]
		self.price     = deal[10]
		self.coords    = '%d,%d,%d' % coords
		self.server    = server or deal[14]
		self.warp      = get_warp(self.server, coords)

class Shop:
	def __init__(self, server, shop):
		coords = shop[-3:]

		self.owner        = shop[0]
		self.single_price = shop[1]
		self.amount       = shop[2]
		self.price        = shop[3]
		self.deal_id      = shop[4]
		self.deal_time    = shop[5]

		self.attestation_time = shop[6]
		self.reason_id        = shop[7]
		self.reason           = shop[8]

		self.coords = '%d,%d,%d' % coords
		self.warp   = get_warp(server, coords)

SHOPS_HISTORY_LAST_SQL           = 'SELECT * FROM shops_history_last();'
SHOPS_HISTORY_LAST_BY_SERVER_SQL = 'SELECT * FROM shops_history_last(%(server_id)s);'
def shops_history_last(request):
	start_time = time()

	server = request.matchdict.get('server')
	if server:
		if server not in servers:
			raise HTTPNotFound('Увы, сервер не найден :-/')
		else:
			server_id = servers[server]

	request = SHOPS_HISTORY_LAST_BY_SERVER_SQL if server else SHOPS_HISTORY_LAST_SQL
	request_params = {'server_id': server_id}

	cursor = sql_connection.cursor()
	cursor.execute(request, request_params)
	history = [Deal(server, deal) for deal in cursor.fetchall()]
	cursor.close()

	template = Template(filename=app_dir + 'templates/shops_history.mako')
	result = template.render(start_time=start_time, server=server, history=history, get_termination=get_termination)
	response = Response(result)

	return response

day  = 3600 * 24
week = day * 7

class Item:
	def __init__(self, id, data, title, icon_image):
		self.id         = id
		self.data       = data
		self.title      = title
		self.icon_image = icon_image
		self.id_with_data = data and "%d:%d" % (id, data) or str(id)
		self.id_with_title = '#%s %s' % (self.id_with_data, self.title.capitalize().replace('_', ' '))

	def set_stats(self, stats):
		self.stats = stats

	def set_prices(self,
			invice_buy_price,  invice_sell_price,
			sandbox_buy_price, sandbox_sell_price,
			amber_buy_price,   amber_sell_price):
		self.invice_buy_price   = invice_buy_price
		self.invice_sell_price  = invice_sell_price
		self.sandbox_buy_price  = sandbox_buy_price
		self.sandbox_sell_price = sandbox_sell_price
		self.amber_buy_price    = amber_buy_price
		self.amber_sell_price   = amber_sell_price

class ItemStats:
	def __init__(self, where_to_buy, where_to_sell, daily, weekly):
		self.where_to_buy  = where_to_buy
		self.where_to_sell = where_to_sell
		self.daily  = daily
		self.weekly = weekly

def get_item_with_prices(values):
	item = Item(*values[:4])
	item.set_prices(*values[4:])
	return item

ITEM_STATS_SQL      = 'SELECT * FROM item_stats(%(server_id)s, %(item_id)s, %(data)s, %(created)s);'
ITEM_SHOPS_BUY_SQL  = 'SELECT * FROM item_shops_buy(%(server_id)s, %(item_id)s, %(data)s);'
ITEM_SHOPS_SELL_SQL = 'SELECT * FROM item_shops_sell(%(server_id)s, %(item_id)s, %(data)s);'
def get_item_stats_data(cursor, server_id, item, start_time):
	day_ago  = start_time - day
	week_ago = start_time - week

	request_params = {'server_id': server_id, 'item_id': item.id, 'data': item.data, 'created': week_ago}

	cursor.execute(ITEM_SHOPS_BUY_SQL, request_params)
	where_to_buy  = [Shop(server_id, shop) for shop in cursor.fetchall()]
	cursor.execute(ITEM_SHOPS_SELL_SQL, request_params)
	where_to_sell = [Shop(server_id, shop) for shop in cursor.fetchall()]

	cursor.execute(ITEM_STATS_SQL, request_params)
	weekly_stats = cursor.fetchall()
	request_params['created'] = day_ago
	cursor.execute(ITEM_STATS_SQL, request_params)
	daily_stats = cursor.fetchall()

	return ItemStats(where_to_buy, where_to_sell, daily_stats, weekly_stats)


def item_view(request):
	start_time = time()

	params = request.matchdict
	item_id = params['item_id']
	if not item_id.isdigit():
		raise HTTPNotFound('Увы, предмет не найден :-/')
	item_id = int(item_id)
	data = int(params.get('data', 0))
	server = params.get('server')
	server_id = servers.get(server)

	cursor = sql_connection.cursor()
	cursor.execute("SELECT title, icon_image FROM items WHERE id = %s AND data = %s;", (item_id, data))
	row = cursor.fetchone()
	if row is None:
		raise HTTPNotFound('Увы, предмет не найден :-/')

	item = Item(item_id, data, *row)

	item_stats_by_server = {}
	template = Template(filename=app_dir + 'templates/item.mako')

	if server:
		stats = get_item_stats_data(cursor, server_id, item, start_time)
		item.set_stats({server: stats})
	else:
		stats = {}
		for server_id in servers_ids:
			stats[servers[server_id]] = get_item_stats_data(cursor, server_id, item, start_time)
		item.set_stats(stats)

	cursor.close()
	sql_connection.rollback()

	result = template.render(start_time=start_time, single_server=server, item=item, get_termination=get_termination)
	response = Response(result)

	return response

def items_view(request):
	start_time = time()

	cursor = sql_connection.cursor()
	cursor.execute("SELECT * FROM items_stats();")
	items = [get_item_with_prices(item) for item in cursor.fetchall()]
	cursor.close()
	sql_connection.rollback()

	template = Template(filename=app_dir + 'templates/items.mako')
	result = template.render(start_time=start_time, items=items)
	response = Response(result)

	return response

def get_servers():
	global servers, servers_ids

	cursor = sql_connection.cursor()
	cursor.execute("SELECT id, name FROM servers WHERE id IN (1, 2, 3);")
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

	config.add_route('item_data', '/item/{item_id}:{data}')
	config.add_route('item',      '/item/{item_id}')
	config.add_route('server_item_data', '/{server}/item/{item_id}:{data}')
	config.add_route('server_item',      '/{server}/item/{item_id}')
	config.add_view(item_view, route_name='item_data')
	config.add_view(item_view, route_name='item')
	config.add_view(item_view, route_name='server_item_data')
	config.add_view(item_view, route_name='server_item')

	config.add_route('items', '/items')
	config.add_view(items_view, route_name='items')

	return config.make_wsgi_app()
