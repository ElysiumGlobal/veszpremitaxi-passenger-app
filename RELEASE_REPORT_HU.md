# Veszprémi Taxi Passenger 1.0.33+43 – UX R1 + cancellation reason profile fallback

## Kiindulási alap

- Codex UX R1 Passenger: `1.0.32+42`
- A teljes UX R1 funkcionalitás változatlanul megmaradt, beleértve a saját érkezési füttyöt, a nagy arrived popupot, a chat hang/badge javítást, a support chatet, a magyar státuszokat és a korábbi lifecycle/rating/route javításokat.

## Új célzott javítás

Ha a sofőr lemondási socket eseménye kimarad, az utas alkalmazás továbbra is a már meglévő két egymást követő, pontosan üres profilválaszos védelemmel igazolja a lemondást. A fallback most az exact booking ID alapján a profil `recent_bookings` listájából kiolvassa a `cancellation_reason` mezőt, és átadja a meglévő nagy lemondási modalnak.

A fallback csak akkor használ okot, ha:

- az exact booking ID egyezik;
- a `recent_bookings` elem státusza `cancelled`;
- a kétpollos lemondási bizonyíték már teljesült.

Más booking vagy nem `cancelled` elem indokát nem használja.

## Módosított production fájlok az UX R1-hez képest

- `lib/feature/home/page/search_driver.dart`
- `pubspec.yaml`

## Backend-feltétel

A koordinált backend patch a Passenger és Driver profilválasz `recent_bookings` listáját booking ID szerint csökkenő sorrendbe rendezi és a legújabb 10 elemet adja. Így az éppen lemondott booking megbízhatóan benne marad a fallbackhez szükséges profiladatban.

## Nem változott

- arrived fütty/popup/rezgés;
- chat és badge működés;
- route-algoritmus és outlier védelem;
- rating booking ID javítás;
- OTP, cash és payment lifecycle;
- Passenger saját lemondási guard;
- kétpollos cancellation guard;
- Firebase/broadcast szerződés.

## Verzió

- `1.0.33+43`

## Ellenőrzési korlátozás

Ebben a környezetben Flutter/Dart CLI nem érhető el, ezért `dart format`, `flutter analyze`, `flutter test` és APK build nem futott. A módosítás statikusan ellenőrzött; fizikai smoke teszt szükséges.
