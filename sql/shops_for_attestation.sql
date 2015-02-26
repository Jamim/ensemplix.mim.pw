CREATE OR REPLACE FUNCTION shops_for_attestation()
RETURNS TABLE(id INTEGER, created INTEGER, server_id SMALLINT, x INTEGER, y INTEGER, z INTEGER) AS $$

DECLARE
	unix_timestamp INTEGER;
	hour_ago INTEGER;
	week_ago INTEGER;

BEGIN
	unix_timestamp = CAST(EXTRACT(epoch FROM now()) AS INTEGER);
	hour_ago = unix_timestamp - 3600;
	week_ago = unix_timestamp - 604800;

	CREATE TEMP TABLE last_deals ON COMMIT DROP AS
		SELECT max(history.id) AS id
		FROM shops_history AS history
		WHERE history.created > week_ago
		GROUP BY history.server_id, history.x, history.y, history.z;

	CREATE TEMP TABLE last_attestation ON COMMIT DROP AS
		SELECT max(attestation.id) AS id, deal_id
		FROM shops_attestation AS attestation
		WHERE deal_id IN (SELECT deals.id FROM last_deals AS deals)
		GROUP BY deal_id;

	RETURN QUERY
		SELECT history.id, history.created, history.server_id, history.x, history.y, history.z
		FROM last_deals
			JOIN shops_history AS history ON history.id = last_deals.id
			LEFT JOIN last_attestation ON last_attestation.deal_id = history.id
			LEFT JOIN shops_attestation AS attestation ON attestation.id = last_attestation.id
		WHERE
			attestation.reason_id IS NULL AND history.created < hour_ago OR
			attestation.reason_id = 1 AND attestation.created < hour_ago
		ORDER BY history.id;
END;

$$ LANGUAGE plpgsql;
