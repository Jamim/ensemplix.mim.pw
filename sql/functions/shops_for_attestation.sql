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

	CREATE TEMP TABLE last_deals (id INTEGER NOT NULL PRIMARY KEY, attestation_id INTEGER) ON COMMIT DROP;
	CREATE INDEX last_deals_attestation_id_idx ON last_deals (attestation_id);
	INSERT INTO last_deals SELECT * FROM last_deals_ids_with_attestation_ids(week_ago);

	RETURN QUERY
		SELECT history.id, history.created, history.server_id, history.x, history.y, history.z
		FROM last_deals AS deals
			JOIN shops_history AS history ON history.id = deals.id
			LEFT JOIN shops_attestation AS attestation ON attestation.id = deals.attestation_id
		WHERE
			attestation.reason_id IS NULL AND history.created < hour_ago OR
			attestation.reason_id = 1 AND attestation.created < hour_ago
		ORDER BY history.id;
END;

$$ LANGUAGE plpgsql;
