CREATE OR REPLACE FUNCTION items_stats()
RETURNS TABLE(
	id INTEGER, data INTEGER, title TEXT, icon_image TEXT,
	davids_min_buy_price  DOUBLE PRECISION, davids_max_sell_price  DOUBLE PRECISION,
	sandbox_min_buy_price DOUBLE PRECISION, sandbox_max_sell_price DOUBLE PRECISION,
	amber_min_buy_price   DOUBLE PRECISION, amber_max_sell_price   DOUBLE PRECISION
) AS $$

DECLARE
	week_ago INTEGER;

BEGIN
	week_ago = CAST(EXTRACT(epoch FROM now() - interval '1 week') AS INTEGER);

	CREATE TEMP TABLE last_deals (id INTEGER NOT NULL PRIMARY KEY, attestation_id INTEGER) ON COMMIT DROP;
	CREATE INDEX last_deals_attestation_id_idx ON last_deals (attestation_id);
	INSERT INTO last_deals SELECT * FROM last_deals_ids_with_attestation_ids(week_ago);

	CREATE TEMP TABLE deals_data (
		server_id INTEGER NOT NULL,
		item_id   INTEGER NOT NULL,
		data      INTEGER NOT NULL,
		price     DOUBLE PRECISION NOT NULL,
		operation BOOLEAN NOT NULL,
		reason_id INTEGER
	) ON COMMIT DROP;

	CREATE INDEX deals_data_server_id_idx ON deals_data (server_id);
	CREATE INDEX deals_data_item_idx      ON deals_data (item_id, data);
	CREATE INDEX deals_data_operation_idx ON deals_data (operation);
	CREATE INDEX deals_data_reason_id_idx ON deals_data (reason_id);

	INSERT INTO deals_data
		SELECT server_id, history.item_id, history.data, 1.*price/amount AS price, operation, reason_id
		FROM last_deals AS deals
			JOIN shops_history AS history ON history.id = deals.id
			LEFT JOIN shops_attestation ON shops_attestation.id = attestation_id;

	RETURN QUERY
		SELECT
			items.id, items.data, items.title, items.icon_image,
			davids_buy.min_price,  davids_sell.max_price,
			sandbox_buy.min_price, sandbox_sell.max_price,
			amber_buy.min_price,   amber_sell.max_price
		FROM items
			LEFT JOIN (SELECT * FROM min_buy_prices(3))   AS davids_buy   ON davids_buy.item_id   = items.id AND davids_buy.data   = items.data
			LEFT JOIN (SELECT * FROM max_sell_prices(3))  AS davids_sell  ON davids_sell.item_id  = items.id AND davids_sell.data  = items.data

			LEFT JOIN (SELECT * FROM min_buy_prices(1))   AS sandbox_buy  ON sandbox_buy.item_id  = items.id AND sandbox_buy.data  = items.data
			LEFT JOIN (SELECT * FROM max_sell_prices(1))  AS sandbox_sell ON sandbox_sell.item_id = items.id AND sandbox_sell.data = items.data

			LEFT JOIN (SELECT * FROM min_buy_prices(11))  AS amber_buy    ON amber_buy.item_id    = items.id AND amber_buy.data    = items.data
			LEFT JOIN (SELECT * FROM max_sell_prices(11)) AS amber_sell   ON amber_sell.item_id   = items.id AND amber_sell.data   = items.data
		ORDER BY items.id, items.data;
END;

$$ LANGUAGE plpgsql;
