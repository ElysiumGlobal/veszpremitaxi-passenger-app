# VTaxi Passenger 1.0.44+54 – színesebb, kompaktabb utas UX

Dátum: 2026-08-08

Alap: Passenger 1.0.43+53. A már működő booking-, route-, GPS-, payment-, Wallet-, Stripe-, QR- és ride-end lifecycle nincs újratervezve.

## Változások

- Kezdőképernyő: a felső címkereső most sötétkék CTA, sárga keresőikonnal és „Kattints ide és keress sofőrt” felirattal.
- Indulási cím keresése: eltűnt a sivár „Search here” megjelenés; sötétkék/sárga ikonok, finom árnyékok, tisztább találatkártyák és színesebb aktuális hely blokk került be.
- Népszerű helyek / keresési találatok: fehér kártyák, visszafogott sötétkék árnyék, sárga-kék ikonrendszer.
- Indulás / Érkezés: a korábbi semleges piros-zöld vizuális nyelv helyett VTaxi sötétkék/sárga stílus működik. A zöld pozitív státuszra, a piros hibára/tiltásra marad.
- Térképes pickup/destination markerek: VTaxi sötétkék/sárga színpárra váltottak.
- Felvételi pont: sötétkék/sárga vissza gomb, „Most itt vagy” jelzés és tisztább pickup kártya.
- Aktív utazás: az „Úton vagyunk…” blokk jóval kisebb lett; megszűnt a nagy zöld autósáv, a hosszú alcím és a több külön metrika-chip. A fontos adatok egy kompakt kártyában maradtak.
- Sofőr információ: a nagy, helypazarló sofőrbox helyett kompakt sofőrsor és információs ikon van. Érintésre egyszerű popup/bottom sheet mutatja a sofőr adatait, hívást és chatet.
- Lemondás: `started` állapottól az utasoldali lemondás el van rejtve és központilag is blokkolva. A Cancel képernyő közvetlen megnyitása sem tud elindítani cancel API-hívást.
- Aktív fuvar alatt állandó, kisméretű alsó sáv: Fuvar / Sofőr / Tárca. A Tárca megnyitható menet közben, és külön „Vissza az aktív fuvarhoz” gomb visz vissza.
- A már korábban kisebbre vett térképméretek megmaradtak; nincs draggable bottom sheet és nincs nagy navigációs újratervezés.

## Nem módosult

- booking create / offer / accept / arrived / OTP / started / completed backend lifecycle
- route számítás és élő GPS/progress algoritmus
- HomeService API szerződés
- payment selection logika
- Wallet service / Stripe / QR / terminál fizetési logika
- rating / ride-end settlement backend flow

## Fontos biztonsági megjegyzés

A Passenger app most `started` állapottól már nem enged lemondást. Ez UI + kliensoldali guard. A backend korábbi tesztjeinkben már 422-vel utasította el a started állapotú cancel kérést; ezen a backend szabályon ez a csomag nem változtat.

## Ellenőrzés

- Módosított Dart fájlok zárójel/sztring/comment szerkezeti ellenőrzése: PASS.
- Célzott UX- és lifecycle-scope statikus ellenőrzések: PASS.
- HomeService, payment selection és Wallet service összehasonlítva az 1.0.43 alaphoz: változatlan.
- Flutter/Dart SDK ebben a környezetben nincs, ezért a fordítás végső bizonyítéka továbbra is Codemagic build + fizikai telefonos teszt.
