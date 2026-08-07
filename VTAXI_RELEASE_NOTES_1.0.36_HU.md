# Veszprémi Taxi Passenger 1.0.36+46

## QR fizetés utasoldali lezárás + fizetésre váró képernyő

- Completed + pending fuvarnál az utas többé nem úgy látja, mintha tovább utazna.
- Új teljes képernyős állapot: **Az utazás véget ért / Fizetésre várunk…**
- Megjelenik a végösszeg és a fizetési mód.
- Ha egy completed fuvarnál a backend már elengedte a `current_booking_id` pointert, az app közvetlenül lekéri a bookinghoz tartozó `/payments/stripe/qr/{booking}/status` végpontot. Ez QR session nélkül is visszaadja a booking aktuális payment mezőit, ezért a fizetési mód nem maradhat beragadva.
- `payment_status=pending` esetén vár.
- `payment_status=paid` esetén a meglévő biztonságos completion flow fut le, majd jöhet a sofőr értékelése.
- A korábbi profile/recent_bookings fallback megmaradt nem-Stripe esetekre.
- Wallet feltöltés UI változatlanul benne maradt.
- Booking create, cash lifecycle, driver app és backend nem módosult.
- Sikeres paid állapot után a completion dialog most explicit **✓ FIZETVE** állapotot és összeget mutat, majd **Sofőr értékelése** gombbal folytatódik.
