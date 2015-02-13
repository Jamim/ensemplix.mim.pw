#!/usr/bin/env python3

import ensemplix_http, ensemplix_players

api_connection = ensemplix_http.get_connection()
history_data = ensemplix_http.get_data(api_connection, 'shops/')
if history_data is None:
	exit(1)
history = history_data['history']

from sys import argv
import psycopg2

password = argv[1]
sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))
cursor = sql_connection.cursor()

cursor.execute("SELECT world, id FROM servers;")
rows = cursor.fetchall()

servers = {}
for world, id in rows:
	servers[world] = id

players = []
items = []
events  = []
for event in history:
	player = event['from'].lower()
	if player not in players:
		players.append(player)

	player = event['to'].lower()
	if player not in players:
		players.append(player)

	item_id = event['item_id']
	if item_id not in items:
		items.append(item_id)

	events.append(event['id'])

players = ensemplix_players.check_players(api_connection, cursor, players)

api_connection.close()
del api_connection


cursor.execute("SELECT id FROM shops_history WHERE id IN %s;", [tuple(events)])
rows = cursor.fetchall()
events = [row[0] for row in rows]

cursor.execute("SELECT id FROM items WHERE id IN %s;", [tuple(items)])
rows = cursor.fetchall()
items = [row[0] for row in rows]

new_items = []
new_events = []
for event in history:
	item_id = event['item_id']
	if item_id not in items:
		new_items.append({'id': item_id, 'title': event['item'], 'icon_image': event['icon_image']})
		items.append(item_id)

	if event['id'] not in events:
		event['server_id'] = servers[event['world']]
		event['from_id']   = players[event['from'].lower()]
		event['to_id']     = players[event['to'].lower()]
		new_events.append(event)

cursor.executemany("INSERT INTO items VALUES (%(id)s, %(title)s, %(icon_image)s);", new_items)
cursor.executemany("INSERT INTO shops_history VALUES (%(id)s, %(created)s, %(server_id)s, %(item_id)s, "
	"%(amount)s, %(price)s, %(operation)s, %(from_id)s, %(to_id)s, %(x)s, %(y)s, %(z)s, %(data)s);", new_events)
cursor.close()

sql_connection.commit()
sql_connection.close()

exit(0)
