#!/bin/bash
DB="vreme.db"
if [ ! -f "$DB" ];
then
echo "Ni baze"
sqlite3 "$DB"<shema.sql
fi
sqlite3 "$DB" <<SQL
.mode csv
DROP TABLE IF EXISTS uvoz_t;
CREATE TABLE uvoz_t (
	MESTO TEXT,
	URA TEXT,
	TEMPERATURA REAL
);
.import trenutno_vreme.csv uvoz_t
INSERT INTO current (
	MESTO,
	URA,
	TEMPERATURA
)
SELECT MESTO , URA , TEMPERATURA FROM uvoz_t;
DROP TABLE uvoz_t;
SQL
echo test
sqlite3 -header -column "$DB" <<SQL
SELECT * FROM current
SQL
