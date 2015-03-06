CREATE TABLE items (
	id		SERIAL NOT NULL,
	data		SERIAL NOT NULL,
	title		TEXT NOT NULL,
	icon_image	TEXT
);

CREATE        INDEX items_id_idx      ON items (id);
CREATE        INDEX items_data_idx    ON items (data);
CREATE UNIQUE INDEX items_id_data_idx ON items (id, data);
