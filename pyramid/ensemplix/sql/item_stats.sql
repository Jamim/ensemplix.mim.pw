SELECT
	operation, count(*), sum(amount) AS sum_amount, sum(price) AS sum_price,
	min(1.*price/amount) AS min_price, 1.*sum(price)/sum(amount) AS avg_price, max(1.*price/amount) AS max_price
FROM shops_history
WHERE server_id = %(server_id)s AND item_id = %(item_id)s AND created > %(created)s
GROUP BY operation ORDER BY operation;
