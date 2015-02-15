SELECT
	shops_history.id, shops_history.created,
	players_from.player AS from, players_to.player AS to, items.title,
	amount, price, operation
FROM shops_history
	JOIN players AS players_from ON players_from.id = from_id
	JOIN players AS players_to   ON players_to.id = to_id
	LEFT JOIN items ON items.id = item_id
WHERE server_id = 3 ORDER BY id DESC LIMIT 32;
