SELECT DISTINCT owners.player AS owner, 1.*price/amount AS price_for_single, amount, price, last_created, shops_history.x, shops_history.y, shops_history.z
FROM shops_history
	JOIN (
		SELECT max(created) AS last_created, x, y, z
		FROM shops_history
		WHERE
			server_id = 3
			AND item_id = %(item_id)s
			AND created > %(created)s
			AND [NOT]operation
		GROUP BY x, y, z
	) AS last_shops_history ON
		created = last_created AND
		shops_history.x = last_shops_history.x AND
		shops_history.y = last_shops_history.y AND
		shops_history.z = last_shops_history.z
	JOIN players AS owners ON owners.id = to_id
WHERE server_id = 3 AND item_id = %(item_id)s AND created > %(created)s AND [NOT]operation
ORDER BY price_for_single[DESC], last_created DESC, amount, x, y, z;
