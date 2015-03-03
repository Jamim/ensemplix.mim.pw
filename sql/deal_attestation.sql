CREATE OR REPLACE FUNCTION deal_attestation(
	prev_deal_id INTEGER, curr_deal_item_id INTEGER, curr_deal_data INTEGER,
	curr_deal_operation BOOLEAN, curr_deal_amount INTEGER, curr_deal_price INTEGER, curr_deal_created INTEGER)
RETURNS void AS $$

DECLARE
	prev_deal RECORD;

	prev_attestation_id INTEGER;
	prev_reason_id      INTEGER;

BEGIN
	IF prev_deal_id IS NOT NULL THEN
		prev_attestation_id = (SELECT max(id) FROM shops_attestation WHERE deal_id = prev_deal_id);
		IF prev_attestation_id IS NOT NULL THEN
			prev_reason_id = (SELECT reason_id FROM shops_attestation WHERE id = prev_attestation_id);
		END IF;

		SELECT item_id, data, operation, amount, price INTO prev_deal FROM shops_history WHERE id = prev_deal_id;

		IF prev_attestation_id IS NULL OR prev_reason_id = 1 THEN
			IF curr_deal_item_id != prev_deal.item_id OR curr_deal_data != prev_deal.data THEN
				INSERT INTO shops_attestation (created, deal_id, player_id, reason_id) VALUES (curr_deal_created, prev_deal_id, 0, 7);
			ELSIF curr_deal_operation = prev_deal.operation AND (curr_deal_amount != prev_deal.amount OR curr_deal_price != prev_deal.price) THEN
				INSERT INTO shops_attestation (created, deal_id, player_id, reason_id) VALUES (curr_deal_created, prev_deal_id, 0, 6);
			END IF;
		ELSIF prev_reason_id IN (2, 4) AND curr_deal_operation != prev_deal.operation THEN
			-- В случае продажи в магазин считаем доступной покупку из него, и наоборот
			INSERT INTO shops_attestation (created, deal_id, player_id, reason_id) VALUES (curr_deal_created, prev_deal_id, 0, 1);
		END IF;
	END IF;
END;

$$ LANGUAGE plpgsql;
