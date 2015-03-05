CREATE OR REPLACE FUNCTION shops_manual_attestation()
RETURNS void AS $$

DECLARE
	week_ago INTEGER;

	last_deal_id INTEGER;
	last RECORD;
	deal RECORD;
	
BEGIN
	week_ago = CAST(EXTRACT(epoch FROM now() - interval '1 week') AS INTEGER);


	CREATE TEMP TABLE last_deals (
		id INTEGER NOT NULL PRIMARY KEY,
		server_id INTEGER NOT NULL,
		x INTEGER NOT NULL,
		y INTEGER NOT NULL,
		z INTEGER NOT NULL
	) ON COMMIT DROP;

	CREATE INDEX last_deals_server_id_xyz_idx ON last_deals (server_id, x, y, z);

	INSERT INTO last_deals SELECT * FROM last_unique_deals(week_ago);


	FOR deal IN SELECT * FROM last_deals LOOP
		last_deal_id = (
			SELECT max(id) FROM last_deals
			WHERE
				server_id = deal.server_id
				AND x = deal.x
				AND y = deal.y
				AND z = deal.z
				AND id > deal.id
		);

		IF last_deal_id IS NOT NULL THEN
			SELECT item_id, data, operation, amount, price, created INTO last FROM shops_history WHERE id = last_deal_id;
			PERFORM deal_attestation(deal.id, last.item_id, last.data, last.operation, last.amount, last.price, last.created);
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;
