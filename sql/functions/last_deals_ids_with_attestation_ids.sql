CREATE OR REPLACE FUNCTION last_deals_ids_with_attestation_ids(min_time INTEGER)
RETURNS TABLE(id INTEGER, attestation_id INTEGER) AS $$

BEGIN
	CREATE TEMP TABLE deals (id INTEGER NOT NULL PRIMARY KEY) ON COMMIT DROP;
	INSERT INTO deals SELECT last_deals.id FROM last_deals_ids(min_time) AS last_deals;

	RETURN QUERY
		SELECT deals.id AS id, max(attestation.id) AS id
		FROM deals
			LEFT JOIN shops_attestation AS attestation ON attestation.deal_id = deals.id
		GROUP BY deals.id;

/*
	-- Альтернативное переусложнённое решение, не дающее прироста производительности
	CREATE TEMP TABLE last_attestation (id INTEGER, deal_id INTEGER NOT NULL PRIMARY KEY) ON COMMIT DROP;
	INSERT INTO last_attestation
		SELECT max(attestation.id) AS id, deal_id
		FROM shops_attestation AS attestation
		WHERE deal_id IN (SELECT deals.id FROM deals)
		GROUP BY deal_id;

	RETURN QUERY
		SELECT deals.id AS id, attestation.id AS id
		FROM deals
			LEFT JOIN last_attestation AS attestation ON attestation.deal_id = deals.id;
*/
END;

$$ LANGUAGE plpgsql;
