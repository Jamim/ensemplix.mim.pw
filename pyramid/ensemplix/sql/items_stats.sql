SELECT
	id, title, icon_image,
	davids_buy.min_price,  davids_sell.max_price,
	sandbox_buy.min_price, sandbox_sell.max_price,
	amber_buy.min_price,   amber_sell.max_price
FROM items
	LEFT JOIN (
		SELECT item_id, min(1.*price/amount) AS min_price
		FROM shops_history
		WHERE NOT operation AND server_id = 3 AND created > %(created)s
		GROUP BY item_id
	) AS davids_buy ON davids_buy.item_id = id
	LEFT JOIN (
		SELECT item_id, max(1.*price/amount) AS max_price
		FROM shops_history
		WHERE operation AND server_id = 3 AND created > %(created)s
		GROUP BY item_id
	) AS davids_sell ON davids_sell.item_id=id
	LEFT JOIN (
		SELECT item_id, min(1.*price/amount) AS min_price
		FROM shops_history
		WHERE NOT operation AND server_id = 1 AND created > %(created)s
		GROUP BY item_id
	) AS sandbox_buy ON sandbox_buy.item_id = id
	LEFT JOIN (
		SELECT item_id, max(1.*price/amount) AS max_price
		FROM shops_history
		WHERE operation AND server_id = 1 AND created > %(created)s
		GROUP BY item_id
	) AS sandbox_sell ON sandbox_sell.item_id=id
	LEFT JOIN (
		SELECT item_id, min(1.*price/amount) AS min_price
		FROM shops_history
		WHERE NOT operation AND server_id = 11 AND created > %(created)s
		GROUP BY item_id
	) AS amber_buy ON amber_buy.item_id = id
	LEFT JOIN (
		SELECT item_id, max(1.*price/amount) AS max_price
		FROM shops_history
		WHERE operation AND server_id = 11 AND created > %(created)s
		GROUP BY item_id
	) AS amber_sell ON amber_sell.item_id=id
ORDER BY id;
