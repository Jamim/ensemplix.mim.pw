SELECT id, title, icon_image, buy_price, sell_price FROM items
	LEFT JOIN (
		SELECT item_id, avg(64.*price/amount) AS buy_price
		FROM shops_history
		WHERE NOT operation AND server_id = 3 AND created > %s
		GROUP BY item_id
	) AS avg_buy ON avg_buy.item_id = id
	LEFT JOIN (
		SELECT item_id, avg(64.*price/amount) AS sell_price
		FROM shops_history
		WHERE operation AND server_id = 3 AND created > %s
		GROUP BY item_id
	) AS avg_sell ON avg_sell.item_id=id
ORDER BY id;
