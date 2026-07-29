# Backend P0 – továbbra is szükséges

A mobilalkalmazások ebben a csomagban már nem ragadnak bent a korábban törölt fuvaron, de a szerveroldali lemondási folyamatot külön javítani kell.

A 2026-07-29-i logban a `POST /bookings/cancel` a booking státuszát már `cancelled` értékre állította, majd a `DriverProfile.is_available` frissítésénél mass-assignment hibával HTTP 500 választ adott.

Kötelező backendjavítás:

1. `DriverProfile.is_available` szabályos módosíthatósága vagy explicit mező-hozzárendelése.
2. A booking lemondása, a sofőr felszabadítása, valamint az utas és a sofőr `current_booking_id` törlése egyetlen adatbázis-tranzakcióban fusson.
3. A már törölt booking újabb lemondása idempotens 200 választ adjon.
4. A profil `current_booking` mezője kizárólag a `current_booking_id` alapján, valóban aktív státusz esetén térjen vissza.
