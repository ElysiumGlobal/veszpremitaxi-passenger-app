# VTaxi Passenger 1.0.38+48

## Bankkártya-kezelő UI/UX

- Új **Bankkártyám** menüpont a Profil képernyőn.
- Új egykártyás bankkártya-kezelő képernyő VTaxi arculattal.
- Egyetlen kártyára tervezett UX; nincs többkártyás lista és nincs alapértelmezett-kártya logika.
- A felület szándékosan nem kér be és nem tárol nyers bankkártyaadatot.
- A **Bankkártya hozzáadása** gomb jelenleg csak a kész UI shellt mutatja; Stripe SetupIntent / saved-card backend integráció nincs ebben a verzióban bekötve.
- A meglévő cash / Wallet / Stripe QR / settlement logika nem változott.

## Verzió

`1.0.38+48`
