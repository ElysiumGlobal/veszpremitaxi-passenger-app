# VTaxi Passenger – sofőrlemondási modal V1

## Baseline

- Passenger: `1.0.30+39`
- Forrás ZIP SHA-256: `6f967c11b0f0f6255873f8ff6f01effe0be243ca4c51d671be202378f49d8fa5`
- Új verzió: `1.0.31+40`

## Módosítás

- Az exact booking-ID-s socket guard változatlan.
- Az utas saját lemondási guardja változatlan.
- A két egymást követő üres profilválaszos fallback változatlan.
- A `cancellation_reason` elsődlegesen a socket `booking` payloadból érkezik; üres értéknél a socket felső szintű mezője a fallback.
- Igazolt sofőrlemondásnál a lokális booking törlődik, a Dashboard route betöltődik, ezzel a SearchDriver polling-, marker- és socket subscriptionjei a meglévő `dispose()` úton leállnak.
- A korábbi kis snackbar helyett nem bezárható modal jelenik meg:
  - `Fuvar lemondva`
  - `A sofőr lemondta a fuvart.`
  - opcionálisan `Indok: …`
- Egyszeri `SystemSoundType.alert` és `HapticFeedback.heavyImpact()`.
- A `Rendben` gomb után biztos Dashboard.
- Nincs új dependency.

## Módosított production fájlok

- `pubspec.yaml`
- `lib/feature/home/controller/home_controller.dart`

A `search_driver.dart` szándékosan nem változott: a meglévő route-csere és `dispose()` már leállítja a képernyő saját pollingját, markeranimációját és subscriptionjeit.

## Nem változott

- Laravel backend
- lifecycle
- cash
- OTP
- chat
- route/ETA
- kétpollos védelem
- rating

## Ellenőrzés

- `git diff --check`: PASS
- statikus célfeltételek: PASS
- zárójelek/kapcsos zárójelek lexikai egyensúlya: PASS
- `dart format`: NEM FUTOTT – a környezetben nincs Dart SDK
- `flutter analyze`: NEM FUTOTT – a környezetben nincs Flutter SDK
- `flutter test`: NEM FUTOTT – a környezetben nincs Flutter SDK

Fizikai teszt és Flutter build továbbra is kötelező.
