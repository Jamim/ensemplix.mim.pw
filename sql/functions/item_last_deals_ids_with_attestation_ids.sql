CREATE OR REPLACE FUNCTION item_last_deals_ids_with_attestation_ids(
	target_server_id INTEGER, target_item_id INTEGER, target_data INTEGER, target_operation BOOLEAN, min_time NUMERIC)
RETURNS TABLE(id INTEGER, attestation_id INTEGER) AS $$

BEGIN
	RETURN QUERY
		SELECT deals.id, max(attestation.id)
		FROM (SELECT * FROM item_last_deals_ids(target_server_id, target_item_id, target_data, target_operation, min_time)) AS deals
			LEFT JOIN shops_attestation AS attestation ON attestation.deal_id = deals.id
		GROUP BY deals.id;
END;

$$ LANGUAGE plpgsql;
