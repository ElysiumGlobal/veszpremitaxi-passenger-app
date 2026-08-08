# Veszprémi Taxi Passenger 1.0.40+50

## Tárca + Bankkártyám egységesítés
A Bankkártyám kezelőfelület most már két helyről érhető el, ugyanarra az egyetlen képernyőre navigálva:

- Profil > Bankkártyám
- Tárca > Bankkártyám

## Tárca új elem
Az Egyenleg feltöltése alatt új Bankkártyám kártya jelenik meg, amely megnyitja a már meglévő BankCardScreen felületet.

Nincs második vagy párhuzamos bankkártya-kezelés: mindkét belépési pont ugyanazt a route-ot használja.

## Megmaradt funkciók
- HU offline fallback + backendről frissíthető hu_app.json
- Profil > Bankkártyám
- Bankkártya UI shell
- Wallet topup
- Wallet ride payment
- Stripe QR settlement
- completed != paid payment gate
- fuvarvégi settlement képernyő
- screen-awake aktív fuvar és settlement alatt
- érkezési fütty és chat hang

## Fontos
A saved-card SetupIntent tényleges Passenger UI bekötése továbbra sem része ennek a kiadásnak. Ez a kiadás kizárólag a meglévő Bankkártyám UI logikus Tárca-belépési pontját adja hozzá.

Booking lifecycle, Wallet motor, Stripe QR, cash és backend payment logika nem változott.
