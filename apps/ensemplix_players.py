def check_players(api_connection, cursor, players_list):
	cursor.execute("SELECT player, id FROM players WHERE lower(player) IN %s;", [tuple(players_list)])
	rows = cursor.fetchall()

	players = {}
	for player, id in rows:
		player = player.lower()
		players[player] = id
		players_list.remove(player)

	if players_list:
		import ensemplix_http

		new_players = []
		for player_name in players_list:
			player = ensemplix_http.get_data(api_connection, 'player/info/%s/' % (player_name,))[0]
			new_players.append(player)
			players[player_name] = player['id']
		cursor.executemany("INSERT INTO players VALUES (%(id)s, %(level)s, %(player)s, %(registration)s, "
			"%(logo_url)s, %(prefix)s, %(name_color)s, %(chat_color)s);", new_players)

	return players
