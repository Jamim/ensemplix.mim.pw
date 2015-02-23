SELECT
	shops_history.id, shops_history.created, operation,
	players_from.player AS client, players_to.player AS owner,
	item_id, shops_history.data, title, icon_image,
	amount, price, x, y, z[server]
FROM shops_history
	JOIN players AS players_from ON players_from.id = from_id
	JOIN players AS players_to   ON players_to.id = to_id
	LEFT JOIN items ON items.id = item_id AND items.data = shops_history.data
[JOIN][WHERE]ORDER BY id DESC LIMIT 32;
