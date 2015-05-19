#!/usr/bin/env python3

from sys import argv
import json, psycopg2, ensemplix_http

ensemplix_http.init_connection()
servers = ensemplix_http.get_data('server/game/')
ensemplix_http.close_connection()

password = argv[1]
sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))
cursor = sql_connection.cursor()

insert_sql = "INSERT INTO servers VALUES (%(id)s, %(name)s, %(maximum)s, " \
	"%(ip)s, %(port)s, %(server_type)s, %(border)s, %(world)s," \
	"%(map)s, %(server_version)s, %(client_version)s);"
server_name = argv[2] if len(argv) == 3 else None
if server_name:
	for server in servers:
		if server['name'] == server_name:
			cursor.execute(insert_sql, server)
else:
	cursor.executemany(insert_sql, servers)
cursor.close()

sql_connection.commit()
sql_connection.close()

exit(0)
