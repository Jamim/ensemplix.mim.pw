import ensemplix_http
from ensemplix_log import log

players_ignore_list = [
	'nike_', 'm4111', 'lixpsx', 'capitan_blek1', 'ddaanniill55',
	'demiyrgiu', 'goshantr693', 'gri2811', 'macho1878',
	'mrgamlet', 'zixe'
]

def insert_players(cursor, players, new_players):
	if not new_players:
		return

	new_players_data = []
	for player in new_players:
		if player in players_ignore_list:
			continue

		player_data = ensemplix_http.get_data('player/info/%s/' % (player,))
		if player_data:
			player_data = player_data[0]
			log('Новый игрок: \033[0;36m%s', player_data['player'], style='0;35')
			new_players_data.append(player_data)
			players[player] = player_data['id']
		else:
			log('Не удалось получить информацию по игроку \033[0;36m%s', player, style='0;31')
			with open('bad_players', 'a') as output:
				output.write(player + '\n')
			players_ignore_list.append(player)

	cursor.executemany("INSERT INTO players VALUES (%(id)s, %(level)s, %(player)s, %(registration)s, "
		"%(logo_url)s, %(prefix)s, %(name_color)s, %(chat_color)s);", new_players_data)

	log('Добавлено игроков: \033[0;36m%d', len(new_players_data), style='0;35')
