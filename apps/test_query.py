#!/usr/bin/env python3

from sys import argv
import psycopg2
from time import time

password, query, count = argv[1], argv[2], int(argv[3])
sql_connection = psycopg2.connect("dbname='ensemplix' user='ensemplix' host='localhost' password='%s'" % (password,))
cursor = sql_connection.cursor()

attempt = 0
while attempt < count:
	attempt += 1
	start_time = time()
	cursor.execute(query)
	rows = cursor.fetchall()
	sql_connection.rollback()
	print("%d:\t%.3f мс" % (attempt, 1000 * (time() - start_time)))

cursor.close()
sql_connection.close()

exit(0)
