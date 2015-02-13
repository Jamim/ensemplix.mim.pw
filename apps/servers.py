#!/usr/bin/env python3

from sys import argv
import json, psycopg2, ensemplix_http

api_connection = ensemplix_http.get_connection()
servers = ensemplix_http.get_data(api_connection, 'server/game/')
api_connection.close()

password = argv[1]
sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))
cursor = sql_connection.cursor()

cursor.executemany("INSERT INTO servers VALUES (%(id)s, %(name)s, %(maximum)s, "
	"%(ip)s, %(port)s, %(server_type)s, %(border)s, %(world)s,"
	"%(map)s, %(server_version)s, %(client_version)s);", servers)
cursor.close()

sql_connection.commit()
sql_connection.close()

exit(0)
