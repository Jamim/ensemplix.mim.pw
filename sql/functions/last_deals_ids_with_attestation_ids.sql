CREATE OR REPLACE FUNCTION last_deals_ids_with_attestation_ids(min_time INTEGER)
RETURNS TABLE(id INTEGER, attestation_id INTEGER) AS $$

BEGIN
	RETURN QUERY
		SELECT deals.id, max(attestation.id)
		FROM (SELECT * FROM last_deals_ids(min_time)) AS deals
			LEFT JOIN shops_attestation AS attestation ON attestation.deal_id = deals.id
		GROUP BY deals.id;
END;

$$ LANGUAGE plpgsql;
