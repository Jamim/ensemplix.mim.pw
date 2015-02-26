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

max_deal_id = 0
existed_deals_ids = set()
if len(argv) < 3:
	cursor.execute("SELECT max(id) FROM shops_history;")
	max_deal_id = cursor.fetchone()[0]
else:
	max_deal_id = int(argv[2])
	cursor.execute("SELECT id FROM shops_history WHERE id > %s;", (max_deal_id,))
	rows = cursor.fetchall()
	existed_deals_ids = {id for id, in rows}

servers = {}
cursor.execute("SELECT world, id FROM servers;")
rows = cursor.fetchall()
for world, id in rows:
	servers[world] = id
	servers[id] = world

cursor.execute("SELECT * FROM attestation_reasons;")
rows = cursor.fetchall()
reasons = dict((id, reason) for id, reason in rows)

cursor.execute("SELECT lower(player), id FROM players;")
rows = cursor.fetchall()
players = dict((player, id) for player, id in rows)

cursor.execute("SELECT id, data FROM items;")
items = cursor.fetchall()


cursor.close()
del cursor


def get_history(offset):
	request = offset and 'shops?offset=%d' % (offset,) or 'shops'
	history_data = ensemplix_http.get_data(api_connection, request)
	history = history_data and history_data['history']
	return history

def get_blocks_history(world, x, y, z):
	global api_connection

	request = 'blocks/location?world=%s&x=%d&y=%d&z=%d' % (world, x, y, z)
	blocks_data = ensemplix_http.get_data(api_connection, request)
	if blocks_data:
		return blocks_data['blocks']
	else:
		api_connection.close()
		api_connection = ensemplix_http.get_connection()
		return None

def check_players(new_players, *players_for_check):
	for player in players_for_check:
		if player not in players and player not in new_players:
			new_players.append(player)

def prepare_data(history, new_players, new_items, new_deals, deals_ids):
	for deal in history:
		client = deal['from'].lower()
		owner  = deal['to'].lower()

		check_players(new_players, client, owner)

		item_id, data = deal['item_id'], deal['data']
		if (item_id, data) not in items:
			title, icon_image = deal['item'], deal['icon_image']
			id_with_data = data and "%d:%d" % (item_id, data) or str(item_id)
			log('\033[0;35mНовый предмет: \033[0;36m#%s %s\033[0m http://ensemplix.mim.pw/item/%s', id_with_data, title, id_with_data)

			items.append((item_id, data))
			new_items.append({'id': item_id, 'data': data, 'title': title, 'icon_image': icon_image})

		deal_id = deal['id']
		if deal_id > max_deal_id and deal_id not in deals_ids:
			new_deals.append(deal)
			deals_ids.add(deal_id)

def update_history():
	global max_deal_id, existed_deals_ids
	new_players, new_items, new_deals, deals_ids = [], [], [], existed_deals_ids

	offset = 0
	complete = False
	new_max_deal_id = max_deal_id

	while not complete:
		history = get_history(offset)
		prepare_data(history, new_players, new_items, new_deals, deals_ids)
		new_max_deal_id = max(new_max_deal_id, history[0]['id'])

		offset += 100
		start_id = history[-1]['id'] - 1
		while start_id in deals_ids:
			offset   += 1
			start_id -= 1

		complete = start_id <= max_deal_id


	max_deal_id = new_max_deal_id

	cursor = sql_connection.cursor()

	ensemplix_players.insert_players(api_connection, cursor, players, new_players)
	ensemplix_items.insert_items(cursor, new_items)
	ensemplix_deals.insert_deals(cursor, servers, players, new_deals)

	cursor.close()
	sql_connection.commit()
	existed_deals_ids.clear()


def shops_attestation():
	cursor = sql_connection.cursor()

	cursor.execute('SELECT * FROM shops_for_attestation();')
	shops_for_attestation = cursor.fetchall()

	count = len(shops_for_attestation)
	index = 0

	for shop in shops_for_attestation:
		world = servers[shop[2]]
		x, y, z = shop[3:]

		reason_id = 1
		blocks = get_blocks_history(world, x, y, z)
		if blocks:
			last_block = blocks[0]
			reason_id = last_block['created'] < shop[1] and 1 or last_block['type'] and last_block['block'] == 68 and 5 or 7

		attestation_time = reason_id == 1 and time() or last_block['created']
		cursor.execute('INSERT INTO shops_attestation (created, deal_id, player_id, reason_id) VALUES (%s, %s, 0, %s);', (attestation_time, shop[0], reason_id))
		sql_connection.commit()

		index += 1
		reason_color = reason_id == 1 and '0;32' or reason_id == 5 and '0;34' or '0;31'
		reason = reasons[reason_id]
		log('Проверен магазин (%d из %d): \033[0;36m%s %d,%d,%d \033[0;35m— \033[%sm%s', index, count, world, x, y, z, reason_color, reason, style='0;35')

	cursor.close()


def update():
	update_history()
	shops_attestation()


minute = 60
slowpoke_k = 0.9989945

interrupted = False
while not interrupted:
	try:
		update()

		delay = (minute - time() % minute) * slowpoke_k
		if delay > 0:
			log("Ожидание %.3f секунды", delay, style='0;32')
			sleep(delay)
	except KeyboardInterrupt:
		interrupted = True
		log('Выполнение прервано пользователем :-)', style='0;31')


api_connection.close()
sql_connection.close()

del api_connection, sql_connection


exit(0)
