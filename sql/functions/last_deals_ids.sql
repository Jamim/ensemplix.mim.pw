CREATE OR REPLACE FUNCTION last_deals_ids(min_time INTEGER)
RETURNS TABLE(id INTEGER) AS $$

BEGIN
	RETURN QUERY
		SELECT max(shops_history.id) AS id
		FROM shops_history
		WHERE created > min_time
		GROUP BY server_id, x, y, z, operation;
END;

$$ LANGUAGE plpgsql;
