#!/usr/bin/env python3

import ensemplix_http, ensemplix_players

api_connection = ensemplix_http.get_connection()
warps_data = ensemplix_http.get_data(api_connection, 'warps/?world=DavidsR3')
if warps_data is None:
	exit(1)
warps = warps_data['warps']

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

owners = []
warps_list  = []
for warp in warps:
	owner = warp['owner'].lower()
	if owner not in owners:
		owners.append(owner)

	warps_list.append(warp['warp'].lower())

players = ensemplix_players.check_players(api_connection, cursor, owners)

api_connection.close()
del api_connection


cursor.execute("SELECT lower(warp) FROM warps WHERE lower(warp) IN %s;", [tuple(warps_list)])
rows = cursor.fetchall()
warps_list = [row[0] for row in rows]

new_warps = []
for warp in warps:
	if warp['warp'].lower() not in warps_list:
		warp['server_id'] = servers[warp['world']]
		warp['owner']     = players[warp['owner'].lower()]
		new_warps.append(warp)

cursor.executemany("INSERT INTO warps (created, server_id, warp, owner, x, y, z, yaw, pitch, greeting) VALUES ("
	"%(created)s, %(server_id)s, %(warp)s, %(owner)s, "
	"%(x)s, %(y)s, %(z)s, %(yaw)s, %(pitch)s,"
	"%(greeting)s);", new_warps)
cursor.close()

sql_connection.commit()
sql_connection.close()

exit(0)
