# Veszprémi Taxi UTASAPP 1.0.15+24

## P0 blokkoló javítás

- A frissen létrehozott booking nem szűnik meg attól, hogy a backend a `data.current_booking_id` mezőt átmenetileg üresen küldi vissza.
- A booking polling a tényleges `current_booking.booking_id` objektumot tekinti mérvadónak.
- Inkonzisztens profilválasz esetén az app nem dobja vissza az utast a főképernyőre, hanem tovább vár socketre / következő pollingra.
- A profil-visszaállítás elfogadja a friss aktív booking objektumot üres segédmező mellett is; a régi bookingok kor szerinti védelme megmaradt.

## Útvonal megjelenés

- A fekete/szürke útvonal helyett 5 px-es VAP-zöld útvonal jelenik meg 9 px-es fehér kontúrral.
- Lekerekített végek és kanyarok.
- A geometria továbbra is a Google Routes/Directions által visszaadott autós útvonal, nem kézzel rajzolt vonal.

## Android

- Hozzáadva: `android.permission.FOREGROUND_SERVICE_LOCATION`.
- Debug verzióazonosító frissítve: `1.0.15+24`.
