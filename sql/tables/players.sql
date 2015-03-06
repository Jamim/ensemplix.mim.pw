CREATE TABLE players (
	id		SERIAL UNIQUE NOT NULL PRIMARY KEY,
	level		SMALLSERIAL	NOT NULL,
	player		TEXT		NOT NULL,
	registration	SERIAL		NOT NULL,
	logo_url	TEXT,
	prefix		TEXT,
	name_color	TEXT,
	chat_color	TEXT
);

CREATE INDEX players_lower_player_idx ON players (lower(player));
