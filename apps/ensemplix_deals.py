from ensemplix_log import log
from ensemplix_players import players_ignore_list

def skip_deal_log(deal, reason):
	log('Пропущена сделка: \033[0;31m%d\033[0;33m: причина: \033[0;31m%s', deal['id'], reason, style='0;33')

def skip_deal_by_world(deal, world):
	skip_deal_log(deal, 'мир \033[0;36m%s\033[0;31m не найден' % world)

def skip_deal_by_player(deal, player):
	skip_deal_log(deal, 'игрок \033[0;36m%s\033[0;31m игнорируется' % player)

def insert_deals(cursor, servers, players, new_deals):
	if not new_deals:
		return

	accepted_deals = []
	for deal in new_deals:
		world = deal['world']
		if world not in servers:
			skip_deal_by_world(deal, world)
			continue

		client = deal['from'].lower()
		owner  = deal['to'].lower()
		if client in players_ignore_list:
			skip_deal_by_player(deal, deal['from'])
			continue
		if owner in players_ignore_list:
			skip_deal_by_player(deal, deal['to'])
			continue

		deal['server_id'] = servers[world]
		deal['client']    = players[client]
		deal['owner']     = players[owner]
		accepted_deals.append(deal)


	cursor.executemany("INSERT INTO shops_history VALUES (%(id)s, %(created)s, %(server_id)s, %(item_id)s, "
		"%(amount)s, %(price)s, %(operation)s, %(client)s, %(owner)s, %(x)s, %(y)s, %(z)s, %(data)s);", accepted_deals)

	log('Добавлено сделок: \033[0;36m%d', len(accepted_deals), style='0;35')
