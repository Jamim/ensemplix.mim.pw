SELECT
	id, items.data, title, icon_image,
	davids_buy.min_price,  davids_sell.max_price,
	sandbox_buy.min_price, sandbox_sell.max_price,
	amber_buy.min_price,   amber_sell.max_price
FROM items
	LEFT JOIN (
		SELECT item_id, data, min(1.*price/amount) AS min_price
		FROM shops_history
		WHERE NOT operation AND server_id = 3 AND created > %(created)s
		GROUP BY item_id, data
	) AS davids_buy ON davids_buy.item_id = id AND davids_buy.data = items.data
	LEFT JOIN (
		SELECT item_id, data, max(1.*price/amount) AS max_price
		FROM shops_history
		WHERE operation AND server_id = 3 AND created > %(created)s
		GROUP BY item_id, data
	) AS davids_sell ON davids_sell.item_id=id AND davids_sell.data = items.data
	LEFT JOIN (
		SELECT item_id, data, min(1.*price/amount) AS min_price
		FROM shops_history
		WHERE NOT operation AND server_id = 1 AND created > %(created)s
		GROUP BY item_id, data
	) AS sandbox_buy ON sandbox_buy.item_id = id AND sandbox_buy.data = items.data
	LEFT JOIN (
		SELECT item_id, data, max(1.*price/amount) AS max_price
		FROM shops_history
		WHERE operation AND server_id = 1 AND created > %(created)s
		GROUP BY item_id, data
	) AS sandbox_sell ON sandbox_sell.item_id=id AND sandbox_sell.data = items.data
	LEFT JOIN (
		SELECT item_id, data, min(1.*price/amount) AS min_price
		FROM shops_history
		WHERE NOT operation AND server_id = 11 AND created > %(created)s
		GROUP BY item_id, data
	) AS amber_buy ON amber_buy.item_id = id AND amber_buy.data = items.data
	LEFT JOIN (
		SELECT item_id, data, max(1.*price/amount) AS max_price
		FROM shops_history
		WHERE operation AND server_id = 11 AND created > %(created)s
		GROUP BY item_id, data
	) AS amber_sell ON amber_sell.item_id=id AND amber_sell.data = items.data
ORDER BY id, items.data;
