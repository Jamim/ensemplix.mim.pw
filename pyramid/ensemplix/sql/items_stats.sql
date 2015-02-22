SELECT id, title, icon_image, avg_buy_price, avg_sell_price FROM items
	LEFT JOIN (
		SELECT item_id, 64.*sum(price)/sum(amount) AS avg_buy_price
		FROM shops_history
		WHERE NOT operation AND server_id = 3 AND created > %s
		GROUP BY item_id
	) AS avg_buy ON avg_buy.item_id = id
	LEFT JOIN (
		SELECT item_id, 64.*sum(price)/sum(amount) AS avg_sell_price
		FROM shops_history
		WHERE operation AND server_id = 3 AND created > %s
		GROUP BY item_id
	) AS avg_sell ON avg_sell.item_id=id
ORDER BY id;
