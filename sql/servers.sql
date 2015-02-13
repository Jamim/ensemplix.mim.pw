CREATE TABLE servers (
	id		SMALLSERIAL UNIQUE NOT NULL PRIMARY KEY,
	name		TEXT		NOT NULL,
	maximum		SMALLSERIAL	NOT NULL,
	ip		TEXT		NOT NULL,
	port		INTEGER		NOT NULL,
	server_type	TEXT		NOT NULL,
	border		INTEGER,
	world		TEXT		NOT NULL,
	map		TEXT,
	server_version	TEXT		NOT NULL,
	client_version	TEXT		NOT NULL
);
