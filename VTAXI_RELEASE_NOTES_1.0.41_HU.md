# Veszprémi Taxi Passenger 1.0.41+51

## Utazás az úticélhoz – UX frissítés

A `started` fuvarállapot alsó utaspanelje kizárólag vizuális/UX frissítést kapott.

### Új megjelenés
- VTaxi zöld, kiemelt „Úton vagyunk az úticélhoz” státuszkártya.
- Finom, folyamatosan mozgó kis taxi animáció egy dekoratív útvonalcsíkon.
- Jól látható úticél-kártya.
- A fuvar távolsága külön pillben jelenik meg, ha rendelkezésre áll.
- Sofőrkártya és indulási/érkezési címek továbbra is megmaradtak.
- A térkép és az élő sofőrmarker változatlan.

### Fontos
- Booking lifecycle nem változott.
- Polling/WebSocket működés nem változott.
- Payment/Wallet/Stripe QR/settlement nem változott.
- Screen-awake, hangok, Bankkártyám és Tárca funkciók megmaradtak.
- Az animáció kizárólag dekoratív, nem állít valótlan hátralévő százalékot.
