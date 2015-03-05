CREATE OR REPLACE FUNCTION max_sell_prices(target_server_id INTEGER)
RETURNS TABLE (item_id INTEGER, data INTEGER, max_price DOUBLE PRECISION) AS $$

BEGIN
	RETURN QUERY
		SELECT deals.item_id, deals.data, max(price)
		FROM deals_data AS deals
		WHERE
			operation
			AND server_id = target_server_id
			AND (reason_id IS NULL OR reason_id = 1)
		GROUP BY deals.item_id, deals.data;
END;

$$ LANGUAGE plpgsql;
