# Veszprémi Taxi Passenger 1.0.37+47

- Wallet/QR/cash completed ride payment settlement recovery: released booking pointer után a bookinghoz kötött authoritative payment-status endpoint alapján folytatja.
- A SearchDriver profil/status polling completed állapotnál leáll; fizetésre várás alatt külön, célzott settlement polling fut.
- Wallet `paid` esetén a váróképernyőből `✓ FIZETVE` → sofőrértékelés folyamat indul.
- SearchDriver/aktív fuvar képernyő alatt a kijelző ébren marad; kilépéskor visszaáll a rendszer normál képernyő-időzítése.
- Az `assets/sounds/` explicit Flutter asset declarationt kapott (korábban nem volt külön felsorolva).
- Taxi-arrived: booking-ID dedupe + popup + erős rezgés + saját WAV fütty, Android raw resource + natív MediaPlayer/audio focus.
- Chat unread N→N+1: saját WAV csippanás + rezgés; első poll néma; ugyanarra az unread count-ra nem ismétel.
- SystemSound hangút kivezetve ezekből a riasztásokból.
- V5 lifecycle/payment backendhez nem nyúl.
