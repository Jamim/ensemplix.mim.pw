SELECT
	shops_history.id,
	players_from.player AS client, operation, players_to.player AS owner,
	items.icon_image, item_id, items.title, amount, price,
	x, y, z,
	shops_history.created[server]
FROM shops_history
	JOIN players AS players_from ON players_from.id = from_id
	JOIN players AS players_to   ON players_to.id = to_id
	LEFT JOIN items ON items.id = item_id
[JOIN][WHERE]ORDER BY id DESC LIMIT 32;
