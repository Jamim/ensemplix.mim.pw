#!/usr/bin/env python3

from sys import argv
import psycopg2
from time import time

password = argv[1]
sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))
cursor = sql_connection.cursor()

if argv[2] == '--reasons':
	cursor.execute('SELECT * FROM attestation_reasons;')
	rows = cursor.fetchall()
	for id, reason in rows:
		print(id, reason)
else:
	player_id = 6319 # Jamim
	deal, reason_id = argv[2], int(argv[3])
	if deal == 'last':
		cursor.execute('INSERT INTO shops_attestation (created, deal_id, player_id, reason_id) '
			'VALUES (%s, (SELECT max(id) FROM shops_history WHERE from_id = %s), %s, %s);', (time(), player_id, player_id, reason_id))
	else:
		deal_id = int(deal)
		cursor.execute('INSERT INTO shops_attestation (created, deal_id, player_id, reason_id) VALUES (%s, %s, %s, %s);', (time(), deal_id, player_id, reason_id))

cursor.close()
sql_connection.commit()
sql_connection.close()

exit(0)
