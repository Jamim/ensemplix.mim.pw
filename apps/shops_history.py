#!/usr/bin/env python3

import ensemplix_http, ensemplix_players, ensemplix_items, ensemplix_deals, ensemplix_warps
from ensemplix_log import log

from sys import argv
from time import time, sleep
import psycopg2

ensemplix_http.init_connection()

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
	existed_deals_ids = {id for id in rows}

servers = {}
cursor.execute("SELECT world, id FROM servers;")
rows = cursor.fetchall()
for world, id in rows:
	servers[world] = id
	servers[id] = world
accepted_servers = (1, 2, 3)

cursor.execute("SELECT * FROM attestation_reasons;")
rows = cursor.fetchall()
reasons = dict((id, reason) for id, reason in rows)

cursor.execute("SELECT lower(player), id FROM players;")
rows = cursor.fetchall()
players = dict((player, id) for player, id in rows)

cursor.execute("SELECT id, data FROM items;")
items = cursor.fetchall()

warps = dict((server_id, set()) for server_id in accepted_servers)
cursor.execute("SELECT server_id, lower(warp) FROM warps WHERE server_id IN %r;" % (accepted_servers,))
rows = cursor.fetchall()
for server_id, warp in rows:
	warps[server_id].add(warp)

cursor.close()
del cursor


def get_history(offset):
	request = offset and 'shops?offset=%d' % (offset,) or 'shops'
	history_data = ensemplix_http.get_data(request)
	history = history_data and history_data['history']
	return history

def get_blocks_history(world, x, y, z):
	request = 'blocks/location?world=%s&x=%d&y=%d&z=%d' % (world, x, y, z)
	blocks_data = ensemplix_http.get_data(request)
	blocks = blocks_data and blocks_data['blocks']
	return blocks

def get_warps(world, offset):
	request = 'warps?world=%s%s' % (world, offset and '&offset=%d' % (offset,) or '')
	warps_data = ensemplix_http.get_data(request)

	if warps_data is None:
		return [], 0

	warps, count = warps_data['warps'], warps_data['count']
	return warps, count

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

def save_data(new_players, new_items, new_deals):
	cursor = sql_connection.cursor()

	ensemplix_players.insert_players(cursor, players, new_players)
	sql_connection.commit()

	ensemplix_items.insert_items(cursor, new_items)
	sql_connection.commit()

	ensemplix_deals.insert_deals(cursor, servers, players, new_deals)

	cursor.close()
	sql_connection.commit()

	new_players.clear()
	new_items.clear()
	new_deals.clear()

def update_history():
	global max_deal_id, existed_deals_ids
	new_players, new_items, new_deals, deals_ids = [], [], [], existed_deals_ids

	offset = 0
	complete = False
	new_max_deal_id = max_deal_id

	while not complete:
		history = get_history(offset)
		if history is None:
			continue

		prepare_data(history, new_players, new_items, new_deals, deals_ids)
		if len(new_deals) > 9000:
			save_data(new_players, new_items, new_deals)
		new_max_deal_id = max(new_max_deal_id, history[0]['id'])

		offset += 100
		start_id = history[-1]['id'] - 1
		while start_id in deals_ids:
			offset   += 1
			start_id -= 1

		complete = start_id <= max_deal_id

	max_deal_id = new_max_deal_id
	save_data(new_players, new_items, new_deals)
	existed_deals_ids.clear()


REASON_OK            = 1
REASON_TERMS_CHANGED = 6
REASON_CLOSED        = 8

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
			reason_id = last_block['created'] < shop[1] and REASON_OK or last_block['type'] and last_block['block'] == 68 and REASON_TERMS_CHANGED or REASON_CLOSED

		attestation_time = reason_id == REASON_OK and time() or last_block['created']
		cursor.execute('INSERT INTO shops_attestation (created, deal_id, player_id, reason_id) VALUES (%s, %s, 0, %s);', (attestation_time, shop[0], reason_id))
		sql_connection.commit()

		index += 1
		reason_color = reason_id == REASON_OK and '0;32' or reason_id == REASON_TERMS_CHANGED and '0;34' or '0;31'
		reason = reasons[reason_id]
		log('Проверен магазин (%d из %d): \033[0;36m%s %d,%d,%d \033[0;35m— \033[%sm%s', index, count, world, x, y, z, reason_color, reason, style='0;35')

	cursor.close()

def update_warps():
	for server_id in accepted_servers:
		world = servers[server_id]
		warps_set = warps[server_id]

		new_warps   = []
		new_players = []

		offset = 0
		count  = 1

		while offset < count:
			fetched_warps, count = get_warps(world, offset)

			for warp in fetched_warps:
				warp_title = warp['warp'].lower()
				if warp_title in warps_set:
					continue

				check_players(new_players, warp['owner'].lower())
				new_warps.append(warp)
				warps_set.add(warp_title)

			offset += 100

		cursor = sql_connection.cursor()

		ensemplix_players.insert_players(cursor, players, new_players)
		sql_connection.commit()

		ensemplix_warps.insert_warps(cursor, server_id, world, players, new_warps)

		cursor.close()
		sql_connection.commit()


warps_update_interval = 1800

current_time = time()
next_warps_update_time = current_time - current_time % warps_update_interval + warps_update_interval

def update():
	global next_warps_update_time

	update_history()

	current_time = time()
	if next_warps_update_time < current_time:
		update_warps()
		next_warps_update_time = current_time - current_time % warps_update_interval + warps_update_interval

	shops_attestation()


shops_check_interval = 180
slowpoke_k = 0.9989945

interrupted = False
while not interrupted:
	try:
		update()

		delay = (shops_check_interval - time() % shops_check_interval) * slowpoke_k
		if delay > 0:
			log("Ожидание %.3f секунды", delay, style='0;32')
			sleep(delay)
	except KeyboardInterrupt:
		interrupted = True
		print('\r', end='')
		log('Выполнение прервано пользователем :-)', style='0;31')


ensemplix_http.close_connection()
sql_connection.close()

del sql_connection


exit(0)
