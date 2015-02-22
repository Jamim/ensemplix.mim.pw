SELECT
	operation, count(*), sum(amount) AS sum_amount, sum(price) AS sum_price,
	min(1.*price/amount) AS min_price, 1.*sum(price)/sum(amount) AS avg_price, max(1.*price/amount) AS max_price
FROM shops_history
WHERE server_id = 3 AND item_id = %s AND created > %s
GROUP BY operation ORDER BY operation;
