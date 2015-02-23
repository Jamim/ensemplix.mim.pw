import ensemplix_http
from ensemplix_log import log


def insert_players(api_connection, cursor, players, new_players):
	if not new_players:
		return

	new_players_data = []
	for player in new_players:
		player_data = ensemplix_http.get_data(api_connection, 'player/info/%s/' % (player,))[0]
		log('Новый игрок: %s', player_data['player'])
		new_players_data.append(player_data)
		players[player] = player_data['id']

	cursor.executemany("INSERT INTO players VALUES (%(id)s, %(level)s, %(player)s, %(registration)s, "
		"%(logo_url)s, %(prefix)s, %(name_color)s, %(chat_color)s);", new_players_data)

	log('Добавлено игроков: %d', len(new_players))
