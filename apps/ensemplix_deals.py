from ensemplix_log import log


def insert_deals(cursor, servers, players, new_deals):
	if not new_deals:
		return

	for deal in new_deals:
		deal['server_id'] = servers[deal['world']]
		deal['client']    = players[deal['from'].lower()]
		deal['owner']     = players[deal['to'].lower()]

	cursor.executemany("INSERT INTO shops_history VALUES (%(id)s, %(created)s, %(server_id)s, %(item_id)s, "
		"%(amount)s, %(price)s, %(operation)s, %(client)s, %(owner)s, %(x)s, %(y)s, %(z)s, %(data)s);", new_deals)

	log('Добавлено сделок: \033[0;36m%d', len(new_deals), style='0;35')
