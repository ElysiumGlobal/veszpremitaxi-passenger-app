# Veszprémi Taxi Passenger 1.0.34+44 – Stripe Wallet feltöltés UI

## Cél
Az utas a meglévő Tárca képernyőről a már telepített és sandboxban bizonyított Stripe wallet-topup backendet használva tudjon egyenleget feltölteni.

## Új funkciók
- Tárca képernyőn új **Egyenleg feltöltése** blokk.
- A feltölthető összegek nem az appba vannak égetve: a backend `allowed_amounts` listájából érkeznek.
- Stripe PaymentSheet alapú natív bankkártyás fizetés.
- Androidon Google Pay támogatás a PaymentSheetben, ha az eszköz és a Stripe konfiguráció támogatja.
- Stripe publishable key a hitelesített backend config API-ból érkezik; Stripe secret nincs az appban.
- Minden feltöltési kérés külön UUID `client_request_id`-t kap.
- A kliens nem tekinti önmagában sikernek a PaymentSheet bezárását: a backend topup státuszát pollolja, és csak `succeeded` után ír ki sikeres jóváírást.
- Sikeres szerveroldali státusz után a Wallet adatokat újratölti.
- Stripe TEST módban a felület külön jelzi, hogy valódi pénzt nem von le.

## Backend API-k
- `GET /api/payments/wallet/stripe/config`
- `POST /api/payments/wallet/stripe/topup`
- `GET /api/payments/wallet/stripe/topup/{topupId}`

## Android platform módosítások
- `flutter_stripe: ^13.1.0`
- `MainActivity` -> `FlutterFragmentActivity`
- `flutterstripe://redirect` intent filter
- Google Pay API meta-data
- Stripe ajánlott ProGuard szabályok

## iOS előkészítés
- minimum iOS 13 a Podfile-ban
- `flutterstripe` URL scheme az Info.plistben
- Apple Pay nincs még bekapcsolva ebben a körben; ehhez külön Merchant ID / entitlement kell.

## Nem változott
- booking lifecycle
- fuvar létrehozás / elfogadás / befejezés
- wallet fuvarfizetés logika
- QR ride payment backend
- mentett kártyák UI-ja
- automatikus saved-card preauth/capture

## Build
A forrás Codemagic workflow-ja `flutter pub get`-et futtat, ezért az új `flutter_stripe` dependency a build során kerül a lockfile-ba. Ebben a futtatókörnyezetben Flutter SDK nem állt rendelkezésre, ezért a végső fordítási ellenőrzés Codemagicben történik.
