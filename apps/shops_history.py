#!/usr/bin/env python3

import ensemplix_http, ensemplix_players, ensemplix_items, ensemplix_deals
from ensemplix_log import log

from sys import argv
from time import time, sleep
import psycopg2

api_connection = ensemplix_http.get_connection()

password = argv[1]
sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))


cursor = sql_connection.cursor()


cursor.execute("SELECT max(id) FROM shops_history;")
max_deal_id = cursor.fetchone()[0]

servers = {}
cursor.execute("SELECT world, id FROM servers;")
rows = cursor.fetchall()
for world, id in rows:
	servers[world] = id

players = {}
cursor.execute("SELECT lower(player), id FROM players;")
rows = cursor.fetchall()
for player, id in rows:
	players[player] = id

cursor.execute("SELECT id, data FROM items;")
items = cursor.fetchall()


cursor.close()
del cursor


def get_history(offset):
	request = offset and 'shops?offset=%d' % (offset,) or 'shops'
	history_data = ensemplix_http.get_data(api_connection, request)
	history = history_data and history_data['history']
	return history

def check_players(new_players, *players_for_check):
	for player in players_for_check:
		if player not in players and player not in new_players:
			new_players.append(player)

def prepare_data(history, new_players, new_items, new_deals, new_deals_ids):
	for deal in history:
		client = deal['from'].lower()
		owner  = deal['to'].lower()

		check_players(new_players, client, owner)

		item_id, data = deal['item_id'], deal['data']
		if (item_id, data) not in items:
			title, icon_image = deal['item'], deal['icon_image']
			id_with_data = data and "%d:%d" % (item_id, data) or str(item_id)
			log('Новый предмет: #%s %s http://ensemplix.mim.pw/item/%s', id_with_data, title, id_with_data)

			items.append((item_id, data))
			new_items.append({'id': item_id, 'data': data, 'title': title, 'icon_image': icon_image})

		deal_id = deal['id']
		if deal_id > max_deal_id and deal_id not in new_deals_ids:
			new_deals.append(deal)
			new_deals_ids.add(deal_id)

def update():
	global max_deal_id
	new_players, new_items, new_deals, new_deals_ids = [], [], [], set()

	offset = 0
	complete = False
	new_max_deal_id = max_deal_id

	while not complete:
		history = get_history(offset)
		prepare_data(history, new_players, new_items, new_deals, new_deals_ids)
		new_max_deal_id = max(new_max_deal_id, history[0]['id'])
		offset += 100
		complete = history[-1]['id'] < max_deal_id + 2 # да-да, именно два


	max_deal_id = new_max_deal_id

	cursor = sql_connection.cursor()

	ensemplix_players.insert_players(api_connection, cursor, players, new_players)
	ensemplix_items.insert_items(cursor, new_items)
	ensemplix_deals.insert_deals(cursor, servers, players, new_deals)

	cursor.close()
	sql_connection.commit()


interrupted = False
while not interrupted:
	try:
		start_time = time()

		update()

		delay = start_time + 60 - time()
		if delay > 0:
			log("Ожидание %.3f секунд", delay)
			sleep(delay)
	except KeyboardInterrupt:
		interrupted = True
		log('Выполнение прервано пользователем :-)')


api_connection.close()
sql_connection.close()

del api_connection, sql_connection


exit(0)
