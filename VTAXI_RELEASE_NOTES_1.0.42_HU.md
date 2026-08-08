# VTaxi Passenger 1.0.42+52 – utasoldali UX frissítés

Dátum: 2026-08-08

Alap: Passenger 1.0.41+51 trip-progress UX. A booking/payment lifecycle, Wallet, Stripe, QR, terminálos fizetés és settlement logika nem lett átírva.

## Változások

- Indulás / Érkezés kártyák: piros és zöld háttér, fehér feliratok és ikonok.
- Úticél megadása: zöld, hangsúlyos címmező, pulzáló cél-pin, magyar szöveg.
- Új „Hol vagyok most?” GPS-kártya az úti cél megadásánál: a telefon aktuális helyével frissíti az indulási pontot.
- Felvételi pont ellenőrzése: pulzáló pin, „Most itt vagy” jelzés, egyértelmű segítség a térkép pontos beállításához.
- Taxi választó: jelentősen nagyobb járműikon és erősebb járműnév.
- Sofőr érkezési információ: élő markerpozíció fallback, így a GPS-becslés és távolság nem marad üres; adat hiányában értelmes töltési állapot jelenik meg.
- „Úton vagyunk az úticélhoz”: a taxi helye már a ténylegesen hátralévő útvonalból becsült haladáshoz igazodik.
- Utazás közben látható: megtett százalék, hátralévő km, becsült perc és GPS állapot.
- A progress a már meglévő útvonal-frissítést használja; új külön Google route API hívás nem került be csak a progress miatt.
- Debug log: a driver_route_points_updated esemény már progress %, hátralévő km és ETA adatot is tartalmaz.

## Nem módosult

- booking create / accept / arrived / started / completed lifecycle
- payment_status=paid kapu
- Wallet fizetés és feltöltés
- Stripe QR / terminal payment
- ride-end settlement és rating flow
- backend API szerződés

## Ellenőrzés

- Módosított Dart fájlok zárójel/sztring/comment szerkezeti ellenőrzése: PASS.
- Célzott statikus feature-checkek: PASS.
- Flutter SDK nem áll rendelkezésre ebben a környezetben, ezért a fordítás végső bizonyítéka Codemagic build + fizikai teszt.
