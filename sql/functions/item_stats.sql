CREATE OR REPLACE FUNCTION item_stats(target_server_id INTEGER, target_item_id INTEGER, target_data INTEGER, min_time NUMERIC)
RETURNS TABLE(
	operation BOOLEAN, deals_count BIGINT, sum_amount BIGINT, sum_price BIGINT,
	min_price NUMERIC, avg_price NUMERIC, max_price NUMERIC
) AS $$

BEGIN
	RETURN QUERY
		SELECT
			history.operation, count(*), sum(amount), sum(price),
			min(1.*price/amount), 1.*sum(price)/sum(amount), max(1.*price/amount)
		FROM shops_history AS history
		WHERE
			server_id = target_server_id
			AND item_id = target_item_id
			AND data = target_data
			AND created > min_time
		GROUP BY history.operation ORDER BY history.operation;
END;

$$ LANGUAGE plpgsql;
