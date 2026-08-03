# Veszprémi Taxi Sofőr 1.0.23+29

## Dart parser / Codemagic fordítási javítás

- A `navigation_screen.dart` három, Dart által félreérthető nullable `Map` indexelése átírva explicit típusellenőrzésre.
- Javítva az `overview_polyline.points`, a `legs[].distance.value` és a `legs[].duration.value` kiolvasása.
- A 1.0.22 összes P0 funkciója változatlanul megmaradt: OTP-ellenőrzés, belső útvonal, stale booking védelem, chat és részletes debug.
