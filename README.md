# BerryBI proovitöö: kus Eestis läheb paremini ja kas vahe kasvab

**Failid:** `berrybi_palgad.sql` (laadimine ja päringud), `palgad.duckdb` (andmebaas), `berrybi_kodutoo.pbix` ja ekraanipilt (töölaud).

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

## 5. Sõnum kliendile

Palga järgi läheb paremini Harju maakonnas, kus keskmine palk oli 2025. aastal 12% üle Eesti keskmise, ja Tartu maakonnas, mis on Eesti keskmisel tasemel; ülejäänud 13 maakonda jäävad 16–25% alla keskmise, madalaim on Valga. Kõrgeima ja madalaima maakonna vahe kasvas 2022. aastal ja on sealt alates veidi kahanenud. Üllatav on, et sellest hoolimata on 13 maakonda 15-st Eesti keskmisest varasemast rohkem maha jäänud – oma positsiooni on parandanud ainult Ida-Viru ja Tartu. Palk ei näita elukallidust ega palgaerinevusi maakonna sees, seega ei ole see täielik heaolu mõõdik. Järgmise sammuna soovitan vaadata omavalitsuste tasandit ning lisada tööhõive ja rahvastiku muutuse, et näha, kas palgaerinevused kattuvad piirkondade elujõulisusega.

## Mida teeksin edasi

Lisaksin töölauale drillthrough-lehe maakonnast omavalitsusteni ja liidaksin piirimuutusega omavalitsuste vana ja uue nime üheks aegreaks.

## AI-tööriistade kasutamine

Kasutasin Claude'i (Anthropic) SQL-päringute ja DAX-meetmete mustandite koostamiseks, töölaua visuaalide ülesehituse aruteluks ning selle dokumendi sõnastuse toimetamiseks. Tõlgenduse ja andmestiku valisin ise, päringud käivitasin ja tulemusi kontrollisin ise ning töölaua ehitasin Power BI-s ise.
