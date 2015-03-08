CREATE OR REPLACE FUNCTION item_shops_sell(target_server_id INTEGER, target_item_id INTEGER, target_data INTEGER)
RETURNS TABLE (
	owner TEXT, single_price NUMERIC, amount SMALLINT, price INTEGER,
	deal_id INTEGER, created INTEGER, attestation_time INTEGER, reason_id INTEGER, reason TEXT,
	x INTEGER, y INTEGER, z INTEGER)
AS $$

DECLARE
	week_ago NUMERIC;

BEGIN
	week_ago = EXTRACT(epoch FROM now() - interval '1 week');

	RETURN QUERY
		SELECT
			owners.player, 1.*history.price/history.amount AS single_price, history.amount, history.price,
			history.id, history.created, attestation.created, COALESCE(attestation.reason_id, 1) AS reason_id, reason.reason,
			history.x, history.y, history.z
		FROM (SELECT * FROM item_last_deals_ids_with_attestation_ids(target_server_id, target_item_id, target_data, 't', week_ago)) AS deals
			JOIN shops_history AS history ON history.id = deals.id
			JOIN players AS owners ON owners.id = to_id
			LEFT JOIN shops_attestation   AS attestation ON attestation.id = attestation_id
			LEFT JOIN attestation_reasons AS reason      ON reason.id = attestation.reason_id
		ORDER BY
			reason_id, single_price DESC, history.id DESC;
END;

$$ LANGUAGE plpgsql;
