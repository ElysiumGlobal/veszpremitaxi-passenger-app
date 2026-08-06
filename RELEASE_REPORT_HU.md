# Veszprémi Taxi Passenger 1.0.30+39 – teljes, összevont forrás

## Kiindulási alap

- Forrás ZIP: `veszpremitaxi-passenger-app-main(1).zip`
- Forrás SHA-256: `5d42bffc9b0794f96a8d34986b7af67df4b26bccdcd1022b31f97d73da00418b`
- Verzió: `1.0.29+38`
- A kiindulási forrás már tartalmazta a route-outlier védelmet, a sofőrlemondási Passenger R1 javítást, a magyar lemondási okokat, az Indulás/Érkezés térképfeliratokat és a Google-becslés rövid tájékoztatóját.

## Ebben a teljes forrásban hozzáadva

1. Passenger chat olvasatlanjelzés:
   - piros `1`, `2`, `3`, majd `3+` badge;
   - 4 másodperces lekérés;
   - háttérben és más route-on nem kérdez le;
   - átmeneti API-hibánál nem törli a legutolsó igazolt jelzést;
   - a meglévő chatküldés és `mark-read` változatlan.

2. Fuvarvégi fekete képernyő javítása:
   - a kötelező köszönő popup megmarad;
   - a popup után az értékelőképernyő új route-ként nyílik meg;
   - nem fut le a hibás teljes stack-visszapoppolás;
   - értékelés, kihagyás és visszalépés után biztos Dashboard.

3. `booking_id = 0` értékelési hiba javítása:
   - a completed booking ID a cleanup előtt megőrződik;
   - explicit átadásra kerül az értékelőképernyőnek;
   - az értékelés ezt az ID-t küldi;
   - nulla vagy hiányzó ID-val az app nem indít hibás értékelési API-kérést.

4. Verzió:
   - `1.0.30+39`

## Érintett fájlok

- `pubspec.yaml`
- `lib/feature/home/controller/home_controller.dart`
- `lib/feature/home/page/rate_driver_screen.dart`
- `lib/feature/home/page/search_driver.dart`
- `lib/feature/home/page/driver_details.dart`
- `lib/feature/home/widget/chat_unread_badge.dart` – új fájl

## Nem módosult

- Laravel backend
- lifecycle státuszok és cash-finalization
- ETA-választás
- OTP
- Firebase/broadcast
- Driver app
- route-algoritmus
- wallet/payment logika

## Ellenőrzések

- `git diff --check`: PASS
- baseline chat patch alkalmazhatósága: PASS
- statikus célfeltételek: PASS – lásd `STATIC_CHECKS.json`
- Flutter analyze/test/build: ebben a környezetben nem futott, mert Flutter/Dart SDK nem érhető el
- fizikai telefonos teszt: még szükséges

## Kötelező fizikai teszt

1. teljes készpénzes fuvar;
2. sofőr `Átadva` / paid;
3. köszönő popup;
4. értékelőképernyő;
5. értékelés elküldése valódi booking ID-val;
6. Dashboard, fekete képernyő nélkül;
7. utas üzenetet kap, miközben nincs nyitva a chat;
8. piros badge megjelenik;
9. chat megnyitásakor az üzenet látható és a badge eltűnik.
