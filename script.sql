CREATE OR REPLACE TABLE palk_raw AS
SELECT *
FROM read_csv('C:/Users/mkari/berrybi/PA107.csv',
              all_varchar = true,
              header      = true);

SELECT * FROM palk_raw LIMIT 10;

SELECT * FROM palk_raw WHERE palk_raw::VARCHAR LIKE '%..%';

CREATE OR REPLACE TABLE palk AS
WITH pikk AS (
    UNPIVOT palk_raw
    ON "2021", "2022", "2023", "2024", "2025"
    INTO NAME aasta VALUE vaartus_tekst
)
SELECT "Näitaja"               AS naitaja,
       "Haldusüksus"           AS haldusuksus,
       CAST(aasta AS INTEGER)  AS aasta,
       CAST(CASE WHEN vaartus_tekst IN ('..', '...') THEN NULL
                 ELSE vaartus_tekst END AS DECIMAL(10, 2)) AS vaartus
FROM pikk;

DESCRIBE palk;

SELECT COUNT(*)                  AS kokku,
       COUNT(vaartus)            AS vaartusega,
       COUNT(*) - COUNT(vaartus) AS puuduvad
FROM palk;

CREATE OR REPLACE TABLE haldusuksus AS
WITH esmane AS (
    SELECT TRIM("Haldusüksus") AS nimi,
           MIN(rowid)          AS rida
    FROM palk_raw
    GROUP BY 1
), tasemega AS (
    SELECT nimi, rida,
           CASE WHEN nimi = 'Eesti'        THEN 'riik'
                WHEN nimi LIKE '% maakond' THEN 'maakond'
                ELSE 'omavalitsus' END     AS tase
    FROM esmane
)
SELECT nimi,
       tase,
       CASE WHEN tase = 'riik' THEN NULL
            ELSE LAST_VALUE(CASE WHEN tase = 'maakond' THEN nimi END IGNORE NULLS)
                     OVER (ORDER BY rida ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
       END AS maakond,
       rida
FROM tasemega;

SELECT tase, COUNT(*) AS yksusi
FROM haldusuksus
GROUP BY tase ORDER BY tase;

SELECT maakond, COUNT(*) AS omavalitsusi
FROM haldusuksus
WHERE tase = 'omavalitsus'
GROUP BY maakond ORDER BY maakond;

CREATE OR REPLACE TABLE palk_eesti AS
SELECT naitaja, aasta, vaartus
FROM palk
WHERE TRIM(haldusuksus) = 'Eesti';

CREATE OR REPLACE TABLE palk_piirkond AS
SELECT h.tase, h.maakond,
       regexp_replace(h.nimi, ', kuni [0-9]{4}$', '') AS haldusuksus,
       p.naitaja, p.aasta,
       MAX(p.vaartus) AS vaartus
FROM palk p
JOIN haldusuksus h ON h.nimi = TRIM(p.haldusuksus)
WHERE h.tase <> 'riik'
GROUP BY ALL;
SELECT (SELECT COUNT(*) FROM palk)                AS kokku,
       (SELECT COUNT(*) FROM palk_eesti)
     + (SELECT COUNT(*) FROM palk_piirkond)       AS jaotatud;

CREATE OR REPLACE VIEW v_piirkond_vs_eesti AS
WITH vordlus AS (
    SELECT p.tase, p.maakond, p.haldusuksus, p.naitaja, p.aasta,
           p.vaartus,
           e.vaartus                                AS eesti_vaartus,
           ROUND(100 * p.vaartus / e.vaartus, 1)    AS protsent_eestist,
           p.vaartus - e.vaartus                    AS vahe_eur
    FROM palk_piirkond p
    JOIN palk_eesti e USING (naitaja, aasta)
)
SELECT *,
       ROUND(protsent_eestist
             - FIRST_VALUE(protsent_eestist) OVER (PARTITION BY haldusuksus, naitaja
                                                   ORDER BY aasta), 1)       AS muutus_pp,
       CASE WHEN vaartus IS NOT NULL
            THEN RANK() OVER (PARTITION BY tase, naitaja, aasta
                              ORDER BY vaartus DESC NULLS LAST) END          AS koht
FROM vordlus;

CREATE OR REPLACE VIEW v_maakondade_vahe AS
SELECT naitaja,
       aasta,
       ARG_MAX(haldusuksus, vaartus)               AS korgeim_maakond,
       MAX(protsent_eestist)                       AS korgeim_pct,
       ARG_MIN(haldusuksus, vaartus)               AS madalaim_maakond,
       MIN(protsent_eestist)                       AS madalaim_pct,
       ROUND(MAX(vaartus) / MIN(vaartus), 2)       AS korgeim_madalaim_suhe,
       ROUND(STDDEV_POP(protsent_eestist), 1)      AS hajuvus_pp
FROM v_piirkond_vs_eesti
WHERE tase = 'maakond'
GROUP BY naitaja, aasta;

SELECT * FROM v_maakondade_vahe ORDER BY naitaja, aasta;

SELECT *
FROM v_piirkond_vs_eesti
WHERE tase = 'maakond'
ORDER BY naitaja, aasta, koht;

COPY (SELECT * FROM palk_piirkond
      ORDER BY tase, maakond, haldusuksus, naitaja, aasta)
TO 'C:/Users/mkari/berrybi/palk_piirkond.csv' (HEADER, DELIMITER ',');

COPY (SELECT * FROM v_piirkond_vs_eesti
      ORDER BY tase, maakond, haldusuksus, naitaja, aasta)
TO 'C:/Users/mkari/berrybi/piirkond_vs_eesti.csv' (HEADER, DELIMITER ',');

COPY (SELECT * FROM v_maakondade_vahe
      ORDER BY naitaja, aasta)
TO 'C:/Users/mkari/berrybi/maakondade_vahe.csv' (HEADER, DELIMITER ',');

CHECKPOINT;
