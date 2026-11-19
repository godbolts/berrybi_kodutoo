# BerryBI proovitöö: kus Eestis läheb paremini ja kas vahe kasvab

**Failid:** `script.sql` (laadimine ja päringud), `palgad.duckdb` (andmebaas), `berrybi_kodutoo.pbix` ja ekraanipilt (töölaud), `PA107.csv` (toorandmed), `piirkond_vs_eesti.csv` (piirkondade transformeeritud andmed),  `maakondade_vahe.csv` (vahe transformeeritud andmed)

## 1. Küsimuse mõtestamine

**Tõlgendus.** Tõlgendan küsimust nii, et „paremini“ tähendab kõrgemat sissetulekut, ja võrdlen Eesti 15 maakonda keskmise brutokuupalga järgi; mediaan on kontrolliks, et tulemus ei sõltu üksikutest kõrgetest palkadest. Vahe muutumist mõõdan maakonna palga suhtena Eesti keskmisesse: kui mahajäävate maakondade protsent tõuseb ja juhtivate oma langeb, siis vahe kahaneb.

**Andmestik.** Statistikaameti tabel [PA107](https://andmed.stat.ee/et/stat/majandus__palk-ja-toojeukulu__palk__aastastatistika/PA107) (keskmine brutokuupalk, mediaan ja töötajate arv haldusüksuse järgi, 2021–2025). See põhineb maksuandmetel ja katab kõiki töötajaid, sisaldab kõiki maakondi ja jääb täielikult 2017. aasta haldusreformi järgsesse perioodi.

**Küsimus kliendile.** Kas brutopalk on teie jaoks sobiv mõõdik selle kohta, kus läheb paremini, või peaks arvesse võtma ka näiteks tööhõivet või rahvastiku muutust? Andmestikku saab hiljem kergesti laiendada.

## 2. Andmeprobleemid

1. **Arvud olid tekstina ja puuduvad väärtused märgitud „..“.** Laadisin faili tekstina, asendasin „..“ NULL-iga (mitte nulliga, sest null palk oleks vale) ja teisendasin väärtused arvudeks. Samas sammus pöörasin aastaveerud ridadeks.
2. **Puuduvad väärtused tulenevad piirimuutustest.** 202 reast 24-s puudub vähemalt üks väärtus (60 väärtust 1010-st, ~6%). Need on kuus omavalitsust, mille piirid muutusid aastatel 2023–2025 (nt „Narva-Jõesuu linn, kuni 2022“ ja „Narva-Jõesuu linn“): vanal piiril üksusel puuduvad andmed pärast muutust, uuel enne seda. Maakonna tasemel analüüsi see ei mõjuta.
3. **Riik, maakonnad ja omavalitsused olid ühes veerus segamini.** Maakonna kuuluvust näitas ainult ridade järjekord. Lisasin taseme ja maakonna veeru ning jagasin andmed riigi ja piirkondade tabeliks, et vältida topeltlugemist.

## 3. SQL-päring

Vaade `v_piirkond_vs_eesti` arvutab iga maakonna palga protsendina Eesti näitajast samal aastal, muutuse protsendipunktides alates 2021. aastast ja järjestuse. Vaade `v_maakondade_vahe` näitab aastate kaupa kõrgeimat ja madalaimat maakonda, nende palkade suhet ja maakondade hajuvust. Protsent Eesti keskmisest eemaldab üldise palgakasvu ja hinnatõusu, nii et aastad on omavahel võrreldavad ja vahe muutus on otse näha.

### 3.1. Pilt

<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/50a4f553-14b2-4aef-b41e-dbf4d68c3c94" />

## 5. Sõnum kliendile

Palga järgi läheb kõige paremini Harju maakonnas, kus keskmine palk oli 2025. aastal 12% üle Eesti keskmise, ja teisena Tartu maakonnas, mis on Eesti keskmisel tasemel. Ülejäänud 13 maakonda jäävad alla keskmise, kuid kõrgeima ja madalaima maakonna vahe on aastatega veidi kahanenud. Üllatav on, et sellegipoolest on oma positsiooni parandanud ainult Ida-Viru ja Tartu maakond. Nende andmete piirang on see, et need ei näita elukallidust ega palgaerinevusi maakonna sees ning palk üksi ei ole täielik heaolu mõõdik. Järgmise sammuna soovitan lisada ostujõu, tööhõive ja rahvastiku muutuse andmed ning vaadata neid omavalitsuse tasemel, et näha piirkondlikke erinevusi täpsemalt.

## AI-tööriistade kasutamine

Kasutasin Claude’i DuckDB kasutamise õppimiseks ja Statistikaameti andmebaasist sobivate andmete kiireks leidmiseks. Lisaks arutasin läbi, kuidas andmeid teisendada ja milliseid näitajaid nende põhjal arvutada. Claude koostas SQL-päringute ja DAX-meetmete mustandid, mida ma kohandasin ja kontrollisin, ning aitas toimetada selle dokumendi sõnastust.
