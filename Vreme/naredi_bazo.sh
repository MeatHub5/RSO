#!/bin/bash
set -u

DB="vreme.db"
ZAGON=$(date '+%F %T')          # npr. 2026-09-04 17:32:10

# --- 1. Ce baze se ni, jo zgradi po shemi -------------------------------
if [ ! -f "$DB" ]; then
    echo "Baze ni, ustvarjam $DB ..."
    sqlite3 "$DB" < shema.sql
fi


sqlite3 "$DB" <<SQL
.mode csv

DROP TABLE IF EXISTS uvoz_t;
CREATE TABLE uvoz_t (cas TEXT, mesto TEXT, temperatura REAL, vlaga INTEGER, veter REAL);
.import --skip 1 TRENUTNO_VREME.csv uvoz_t
INSERT INTO trenutno (pobrano_ob, cas, mesto, temperatura, vlaga, veter)
SELECT '$ZAGON', cas, mesto, temperatura, vlaga, veter FROM uvoz_t;
DROP TABLE uvoz_t;

DROP TABLE IF EXISTS uvoz_n;
CREATE TABLE uvoz_n (mesto TEXT, datum TEXT, tmax REAL, tmin REAL, padavine REAL);
.import --skip 1 NAPOVED_VREMENA.csv uvoz_n
INSERT OR IGNORE INTO napoved (pobrano_ob, mesto, datum, tmax, tmin, padavine)
SELECT '$ZAGON', mesto, datum, tmax, tmin, padavine FROM uvoz_n;
DROP TABLE uvoz_n;

SQL


# --- 3. Povzetek --------------------------------------------------------
echo
echo "Zagon $ZAGON uvozen v $DB"
sqlite3 -header -column "$DB" <<'SQL'
SELECT * FROM trenutno
SQL
