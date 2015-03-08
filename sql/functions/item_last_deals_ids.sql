CREATE OR REPLACE FUNCTION item_last_deals_ids(target_server_id INTEGER, target_item_id INTEGER, target_data INTEGER, target_operation BOOLEAN, min_time NUMERIC)
RETURNS TABLE (id INTEGER) AS $$

BEGIN
	RETURN QUERY
		SELECT max(shops_history.id)
		FROM shops_history
		WHERE
			server_id     = target_server_id
			AND item_id   = target_item_id
			AND data      = target_data
			AND operation = target_operation
			AND created > min_time
		GROUP BY x, y, z;
END;

$$ LANGUAGE plpgsql;
