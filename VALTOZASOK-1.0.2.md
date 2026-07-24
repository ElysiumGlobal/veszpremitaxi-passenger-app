# Veszprémi Taxi utasapp – 1.0.2+11

## Elkészült

- Új sötét VAP betöltőképernyő Androidon és Flutterben.
- Új, teljes képes magyar onboarding három oldallal.
- Az onboarding egyszer újra megjelenik a frissített kulcs miatt.
- Új bejelentkezőképernyő: e-mail + jelszó az elsődleges út.
- A telefonszámos OTP-belépés kikerült a látható folyamatból.
- Firebase kikapcsolt állapotban az e-mailes belépés közvetlenül a Laravel `user/login/password` végpontját hívja.
- Google/Apple belépési gomb csak a saját Veszprémi Taxi Firebase/app-konfiguráció aktiválása után jelenik meg.
- A gyári Firebase-projekt nem kerül használatba.
- Magyar alapnyelv, magyar dátum/idő és forintos formázás.
- A foglalási gomb fordítása: `Taxi rendelése`.

## Szándékosan nem változott

- Laravel `DEMO_MODE`.
- Foglalás létrehozási és megerősítési logika.
- Sofőr automatikus demo-hozzárendelése.
- Google/Firebase éles kulcsok és konfigurációk.
- Utas appikon.

## Következő technikai lépés

A saját Firebase-projekt létrehozása után cserélni kell az Android/iOS Firebase fájlokat, majd a `lib/utils/build_config.dart` fájlban a `firebaseEnabled` értéket `true`-ra állítani. Ezután külön ellenőrzendő a Google-belépés és a push értesítés.
