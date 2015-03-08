CREATE TABLE shops_history (
	id		SERIAL UNIQUE NOT NULL PRIMARY KEY,
	created		SERIAL		NOT NULL,
	server_id	SMALLSERIAL	NOT NULL,
	item_id		INTEGER		NOT NULL,
	amount		SMALLSERIAL	NOT NULL,
	price		SERIAL		NOT NULL,
	operation	BOOLEAN		NOT NULL,
	from_id		SERIAL		NOT NULL,
	to_id		SERIAL		NOT NULL,
	x		INTEGER		NOT NULL,
	y		INTEGER		NOT NULL,
	z		INTEGER		NOT NULL,
	data		INTEGER		NOT NULL
);

CREATE INDEX shops_history_created_idx   ON shops_history (created);
CREATE INDEX shops_history_server_id_idx ON shops_history (server_id);
CREATE INDEX shops_history_item_id_idx   ON shops_history (item_id);
CREATE INDEX shops_history_operation_idx ON shops_history (operation);
CREATE INDEX shops_history_from_id_idx   ON shops_history (from_id);
CREATE INDEX shops_history_to_id_idx     ON shops_history (to_id);
CREATE INDEX shops_history_xyz_idx       ON shops_history (x, y, z);
CREATE INDEX shops_history_data_idx      ON shops_history (data);

CREATE INDEX shops_history_item_deals_idx ON shops_history (server_id, item_id, data, operation);
