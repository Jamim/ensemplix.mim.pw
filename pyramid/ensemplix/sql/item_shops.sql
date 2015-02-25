DROP TABLE IF EXISTS last_deals;
DROP TABLE IF EXISTS last_attestation;

CREATE TEMP TABLE last_deals AS
	SELECT max(id) AS id
	FROM shops_history
	WHERE
		server_id = %(server_id)s AND
		item_id   = %(item_id)s   AND
		data      = %(data)s      AND
		created   > %(created)s   AND
		[NOT]operation
	GROUP BY x, y, z;

CREATE TEMP TABLE last_attestation AS
	SELECT max(id) AS id, deal_id
	FROM shops_attestation
	WHERE deal_id IN (SELECT id FROM last_deals)
	GROUP BY deal_id;

SELECT
	owners.player AS owner, 1.*price/amount AS single_price, amount, price,
	history.id, history.created, COALESCE(attestation.reason_id, 1) AS reason_id, reason.reason,
	x, y, z
FROM shops_history AS history
	JOIN last_deals ON last_deals.id = history.id
	JOIN players AS owners ON owners.id = to_id
	LEFT JOIN last_attestation ON last_attestation.deal_id = history.id
	LEFT JOIN shops_attestation   AS attestation ON attestation.id = last_attestation.id
	LEFT JOIN attestation_reasons AS reason      ON reason.id = reason_id
ORDER BY
	reason_id, single_price[DESC], history.id DESC;
