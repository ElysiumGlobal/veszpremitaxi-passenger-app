# Veszprémi Taxi Passenger 1.0.39+49

## Összefésült baseline
Ez a kiadás egyesíti a Passenger 1.0.38 HU remote localization ágát és a Passenger 1.0.38 bankkártya UI ágát.

## Megmaradt működő funkciók
- V5-kompatibilis passenger ride/payment flow
- Wallet feltöltés és Wallet ride payment
- Stripe QR settlement
- completed != paid payment gate
- fizetésre váró settlement képernyő
- screen-awake aktív fuvar és settlement alatt
- érkezési fütty és chat hang
- HU offline fallback + backendről frissíthető hu_app.json

## Újonnan összeolvasztva
- Profil > Bankkártyám menüpont
- Bankkártya UI képernyő
- credit_card.svg ikon
- bankkártya UI nyelvi kulcsok helyi HU fallbackben
- bankkártya UI kulcsok a központi hu_app.json backend csomagban

## Fontos
A Bankkártyám képernyő jelenleg UI shell. A saved-card backend alap külön már létezik, de a SetupIntent tényleges Passenger UI bekötése nem része ennek a merge-nek.

Booking lifecycle, Wallet motor, Stripe QR és cash logika nem lett átírva.
