CREATE OR REPLACE FUNCTION last_unique_deals(min_time INTEGER)
RETURNS TABLE(id INTEGER, server_id SMALLINT, x INTEGER, y INTEGER, z INTEGER) AS $$

BEGIN
	RETURN QUERY
		SELECT
			max(history.id) AS id,
			history.server_id,
			history.x,
			history.y,
			history.z
		FROM shops_history AS history
		WHERE created > min_time
		GROUP BY
			history.server_id, history.x, history.y, history.z,
			item_id, data, amount, price, operation;
END;

$$ LANGUAGE plpgsql;
