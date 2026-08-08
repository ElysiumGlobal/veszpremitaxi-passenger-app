# VTaxi Passenger 1.0.43+53 – kompakt UX finomhangolás

Dátum: 2026-08-08

Alap: Passenger 1.0.42+52. Ez a kör kizárólag vizuális/területgazdálkodási finomhangolás. A booking-, payment-, Wallet-, Stripe-, QR-, terminál-, GPS- és ride lifecycle logika nem lett átírva.

## Változások

- Taxi választó térképe: 430.h → 365.h, hogy több hely maradjon az alsó tartalomnak.
- Felvételi pont térképe: 430.h → 365.h.
- Aktív/kereső fuvar térképe: 425.h → 380.h; a meglévő térképes működés változatlan.
- Indulás / Érkezés kártyák kompaktabbak: kisebb belső padding, ikon, címke és függőleges távolság.
- A „Hol vagyok most?” GPS-kártya kisebb lett, funkciója változatlan.
- A felvételi pont alatti információs rész enyhén kompaktabb lett.
- Címkeresési találatok külön, finom kártyás megjelenést kaptak nagyon enyhe árnyékkal és vékony szegéllyel.
- A találatok közti erős elválasztó vonalak helyett kis térköz van.
- Nincs draggable/bottom-sheet átalakítás, nincs új navigációs viselkedés.

## Szándékosan nem módosult

- `HomeController` és booking create/accept/cancel állapotkezelés
- Passenger payment settlement és `payment_status=paid` kapu
- Wallet / Stripe / QR / terminal payment
- sofőr GPS és route/progress számítás
- backend API szerződés
- járműkártya és a 1.0.42-ben megnövelt taxi ikon

## Ellenőrzés

- A 1.0.42-höz képest csak a felsorolt UX Dart fájlok, a verzió és a release/static-check fájlok változtak.
- Célzott statikus feature-checkek: PASS.
- Flutter/Dart SDK ebben a környezetben nem érhető el, ezért a fordítás végső bizonyítéka továbbra is Codemagic build + fizikai telefonos teszt.
