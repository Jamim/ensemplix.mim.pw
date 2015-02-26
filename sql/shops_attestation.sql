CREATE TABLE shops_attestation (
	id		SERIAL UNIQUE NOT NULL PRIMARY KEY,
	created		SERIAL  NOT NULL,
	deal_id		SERIAL  NOT NULL,
	player_id	INTEGER NOT NULL,
	reason_id	SERIAL  NOT NULL,
	proofpic	TEXT
);

CREATE INDEX shops_attestation_created_idx   ON shops_attestation (created);
CREATE INDEX shops_attestation_deal_id_idx   ON shops_attestation (deal_id);
CREATE INDEX shops_attestation_player_id_idx ON shops_attestation (player_id);
CREATE INDEX shops_attestation_reason_id_idx ON shops_attestation (reason_id);
