CREATE OR REPLACE FUNCTION shops_history_last()
RETURNS TABLE (
	id INTEGER, created INTEGER, operation BOOLEAN,
	client TEXT, owner TEXT,
	item_id INTEGER, data INTEGER, title TEXT, icon_image TEXT,
	amount SMALLINT, price INTEGER, x INTEGER, y INTEGER, z INTEGER,
	server TEXT
) AS $$

BEGIN
	RETURN QUERY
		SELECT
			history.id, history.created, history.operation,
			players_from.player, players_to.player,
			history.item_id, history.data, items.title, items.icon_image,
			history.amount, history.price, history.x, history.y, history.z,
			servers.name
		FROM shops_history AS history
			JOIN players AS players_from ON players_from.id = from_id
			JOIN players AS players_to   ON players_to.id   = to_id
			JOIN items   ON items.id = history.item_id AND items.data = history.data
			JOIN servers ON servers.id = server_id
		ORDER BY id DESC LIMIT 32;
END;

$$ LANGUAGE plpgsql;
