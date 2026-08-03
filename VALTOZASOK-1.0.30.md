# Veszprémi Taxi SOFŐRAPP 1.0.30+36

## Érkezési idő és fuvar-elfogadás

- Új fuvar elfogadása előtt kötelező 5, 10, 15, 20 vagy 25 perces várható érkezést választani.
- Az alkalmazás `eta_minutes` mezővel küldi a vállalt időt a meglévő `update-status` végpontra.
- A backend pontos `driver_expected_arrival_at` időpontot számol és ment.
- Több sofőr egyidejű elfogadásánál csak az első nyerhet. A többiek üzenete: **„A címet másik sofőr felvette.”**

## Egyszerűsített sofőrfelület

- A SOFŐRAPP főképernyőjéről és aktívfuvar-képernyőjéről kikerült a zavaró térkép.
- A GPS-helyzetküldés, az online állapot, a háttérben futó helyzetstream és a backend-frissítés megmaradt.
- Az operátor és az UTASAPP továbbra is használhatja a sofőr aktuális pozícióját.

## Aktív fuvar és fuvarlista

- A Fuvarok képernyő tetején külön **ÉLŐ FUVAR** kártya jelenik meg.
- Az aktív kártyán látható az utas, a státusz, a vállalt/pontos érkezési idő, a felvételi cím és az úti cél.
- Közvetlen Hívás, Chat és Megnyitás gomb került rá.
- Az app újranyitásakor a meglévő profil/current_booking helyreállítás továbbra is betölti az aktív fuvart.

## Backend

A `backend-tools/vtaxi-driver-eta-backend-patch-20260802.php` telepítő:

- létrehozza a `bookings.driver_eta_minutes` mezőt;
- létrehozza a `bookings.driver_expected_arrival_at` mezőt;
- bekapcsolja az atomikus első-elfogadó védelmet;
- kibővíti a `BookingStatusChanged` eseményt az ETA-adatokkal;
- telepítés előtt biztonsági mentést készít.
