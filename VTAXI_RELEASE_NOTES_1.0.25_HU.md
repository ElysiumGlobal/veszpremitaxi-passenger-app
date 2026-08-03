# Veszprémi Taxi Utas 1.0.25+34

## Javítások

- A térkép több Google autós útvonalat kér le, és a legrövidebb ésszerű útvonalat választja.
- A kerülőút felismerése légvonal/útvonal aránnyal történik.
- A Routes API hibája vagy tiltása esetén Directions API alternatívák, majd a korábbi polyline megoldás következik.
- A kiválasztott útvonal távolsága és ideje jelenik meg az utas felületén.
- A kiválasztott útvonal geodesic összekötés nélkül, valós úthálózati pontokból rajzolódik.
- Megszűnt a `firebaseMessaging` késői inicializálásából eredő összeomlás.
- A működő Firebase Auth, Google-belépés, e-mailes belépés és e-mailküldés változatlan maradt.
- Tartós, teljes körű debugnapló megmaradt.

## Build

Codemagic workflow: `android-debug`

Elvárt verzió: `1.0.25+34`
