CREATE OR REPLACE FUNCTION shop_attestation()
RETURNS TRIGGER AS $$

DECLARE
	prev_deal RECORD;

BEGIN
	FOR prev_deal IN
		SELECT max(id) AS id FROM shops_history AS deals
		WHERE
				deals.server_id = NEW.server_id
				AND deals.x = NEW.x
				AND deals.y = NEW.y
				AND deals.z = NEW.z
				AND deals.created < NEW.created
		GROUP BY operation
	LOOP
		PERFORM deal_attestation(prev_deal.id,  NEW.item_id, NEW.data, NEW.operation, NEW.amount, NEW.price, NEW.created);
	END LOOP;

	RETURN NEW;
END;

$$ LANGUAGE plpgsql;
