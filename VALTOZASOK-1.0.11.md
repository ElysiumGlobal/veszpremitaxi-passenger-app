# Veszprémi Taxi Utas 1.0.11+20

## Teljes körű, szűrt utasoldali debug

- A standalone debuggyűjtő már a sofőr (`role_id=2`) mellett az utast (`role_id=3`) is fogadja.
- Minden Laravel API-kéréshez naplózza a metódust, végpontot, választ, HTTP-státuszt és időtartamot.
- A napló szűri a tokent, jelszót, telefonszámot, e-mailt, nevet, címet, képet és az utazási kód értékét.
- Naplózza az alkalmazás életciklusát, képernyőváltásait és a nem kezelt Flutter/Dart hibákat.
- Naplózza a socket kapcsolatot, eseménytípust, booking-egyezést és a sofőrpozíció feldolgozását.
- A socket `data` mező String és már dekódolt Map formátumát egyaránt kezeli.
- Naplózza a booking státuszát, az utazási kód meglétét és hosszát, de magát a kódot nem.
- Naplózza a Google Places és geokódolási hívások státuszát, idejét és eredményszámát, API-kulcs nélkül.
- A szerveroldali snapshot megmutatja, hogy az `otp` és `trip_code` mezők léteznek-e, milyen hosszúak és egyeznek-e, az értékük felfedése nélkül.
- A szerveroldali snapshot tartalmazza a booking, sofőr, utas, helyzet, jelenlét és chat állapotának szűrt metaadatait.

## Verzió

- Flutter verzió: `1.0.11+20`
- Csomag: `hu.veszpremitaxi.passenger`
