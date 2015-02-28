from ensemplix_log import log
from ensemplix_players import players_ignore_list


def insert_deals(cursor, servers, players, new_deals):
	if not new_deals:
		return

	accepted_deals = []
	for deal in new_deals:
		client = deal['from'].lower()
		owner  = deal['to'].lower()
		if client in players_ignore_list or owner in players_ignore_list:
			log('Пропущена сделка: \033[0;31m%d', deal['id'], style='0;33')
			continue

		deal['server_id'] = servers[deal['world']]
		deal['client']    = players[client]
		deal['owner']     = players[owner]
		accepted_deals.append(deal)


	cursor.executemany("INSERT INTO shops_history VALUES (%(id)s, %(created)s, %(server_id)s, %(item_id)s, "
		"%(amount)s, %(price)s, %(operation)s, %(client)s, %(owner)s, %(x)s, %(y)s, %(z)s, %(data)s);", accepted_deals)

	log('Добавлено сделок: \033[0;36m%d', len(accepted_deals), style='0;35')
