-- Create the tables to house each days' ranks, and the diffs

CREATE DATABASE IF NOT EXISTS pkomon;
use pkomon;

CREATE TABLE IF NOT EXISTS rank (
	date			DATE NOT NULL DEFAULT '0000-00-00',
	server			VARCHAR(32) NOT NULL,
	character_name	VARCHAR(32) NOT NULL, -- TODO find out this limit
	rank			SMALLINT NOT NULL,
	class			SMALLINT NOT NULL DEFAULT 0,
	level			SMALLINT NOT NULL DEFAULT 0,

	PRIMARY KEY (date, server, character_name),
	INDEX (server, date),
	INDEX (server, character_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS diff (
	date			DATE NOT NULL DEFAULT '0000-00-00',
	server			VARCHAR(32) NOT NULL,
	character_name	VARCHAR(32) NOT NULL, -- TODO find out this limit
	difference		SMALLINT NOT NULL,

	PRIMARY KEY (date, server, character_name),
	INDEX (server, date),
	INDEX (server, character_name)
) ENGINE=InnoDB;

