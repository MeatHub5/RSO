-- shema.sql  --  zgradi prazno bazo za vremensko postajo
-- Zagon:  sqlite3 vreme.db < shema.sql
--
-- Vse tabele imajo stolpec pobrano_ob: to je ura zagona skripte.
-- Zaradi njega baza hrani ZGODOVINO - vsak zagon doda nov sveženj vrstic
-- in stare se ne prepisejo. Prav to je razlog, da uporabljamo bazo in ne CSV.

CREATE TABLE IF NOT EXISTS trenutno (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    pobrano_ob  TEXT NOT NULL,          -- kdaj smo pobrali
    cas         TEXT NOT NULL,          -- cas meritve, ki ga vrne API
    mesto       TEXT NOT NULL,
    temperatura REAL,
    vlaga       INTEGER,
    veter       REAL
);

CREATE TABLE IF NOT EXISTS urno (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    pobrano_ob  TEXT NOT NULL,
    mesto       TEXT NOT NULL,
    cas         TEXT NOT NULL,          -- npr. 2026-09-04T13:00
    temperatura REAL,
    vlaga       INTEGER,
    veter       REAL,
    UNIQUE (pobrano_ob, mesto, cas)     -- isti zagon ne more dvakrat vpisati iste ure
);

CREATE TABLE IF NOT EXISTS napoved (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    pobrano_ob  TEXT NOT NULL,
    mesto       TEXT NOT NULL,
    datum       TEXT NOT NULL,          -- npr. 2026-09-05
    tmax        REAL,
    tmin        REAL,
    padavine    REAL,
    UNIQUE (pobrano_ob, mesto, datum)
);

-- Indeksa pospesita poizvedbe, ki filtrirajo po teh stolpcih.
-- Pri stotih vrsticah razlike ne boste opazili, pri sto tisoc pa ogromno.
CREATE INDEX IF NOT EXISTS idx_urno_mesto_cas ON urno (mesto, cas);
CREATE INDEX IF NOT EXISTS idx_napoved_datum  ON napoved (datum);
