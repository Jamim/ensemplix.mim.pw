SELECT
	operation, count(*), sum(amount), sum(price),
	min(1.*price/amount), avg(1.*price/amount), max(1.*price/amount)
FROM shops_history
WHERE server_id = 3 AND item_id = %s AND created > %s
GROUP BY operation ORDER BY operation;
