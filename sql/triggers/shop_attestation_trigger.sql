CREATE TRIGGER shop_attestation
	BEFORE INSERT ON shops_history
	FOR EACH ROW EXECUTE PROCEDURE shop_attestation();
