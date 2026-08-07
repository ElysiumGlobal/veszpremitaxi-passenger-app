# Veszprémi Taxi Passenger 1.0.35+45

## Payment gate javítás

- `completed` fuvar többé nem zárulhat le csak a booking pointer eltűnése miatt.
- Az utasapp csak `payment_status = paid` esetén nyithatja meg a fuvar lezárását/sofőrértékelést.
- A szabály fizetési módtól független: cash, wallet, Stripe QR és későbbi mentett kártya esetén is ugyanaz.
- A `current_booking` pointer megszűnése után a polling a profil `recent_bookings` rekordjából veszi át az autoritatív `payment_method`, `payment_status` és `online_paid_amount` mezőket.
- Megszűnt a korábbi veszélyes fallback, amely pointer-release alapján lokálisan `paid` értéket gyártott.
- A Wallet feltöltés UI változatlanul megmaradt az 1.0.34 alapból.
- Backend, driver app és QR backend nincs módosítva ebben a csomagban.

## Elvárt teszt

1. Fuvar `completed`, `payment_status=pending`.
2. Sofőr megnyomja a `FIZETÉS TELEFONNAL` gombot.
3. Utasapp NEM nyit értékelést és NEM állítja lokálisan fizetettre a fuvart.
4. Stripe fizetés sikeres.
5. Backend booking `payment_status=paid`.
6. Utasapp polling ezt a `recent_bookings` rekordból átveszi.
7. Csak ekkor zárul a fuvar és nyílhat meg a sofőrértékelés.
