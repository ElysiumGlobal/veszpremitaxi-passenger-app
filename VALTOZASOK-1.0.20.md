# Veszprémi Taxi UTASAPP 1.0.20+29

## Firebase belépés – Android első ütem

- A Veszprémi Taxi saját Firebase projektje bekerült az Android UTASAPP-ba.
- Csomagnév: `hu.veszpremitaxi.passenger`.
- Firebase projekt: `vtaxi-503221`.
- Az Android Google OAuth kliens és a Codemagic debug SHA-1 konfigurálva.
- Az Email/Password és a Google belépés aktív.
- A vendég mód nincs engedélyezve.
- A térkép és a rendelési felület csak Firebase + Laravel belépés után nyílik meg.
- A korábbi debug teszt e-mail/jelszó előtöltés megszűnt.
- Új e-mail-címnél a Firebase-fiók automatikusan létrejön.
- A megerősítő e-mail elküldésre kerül, de az első belépést nem blokkolja.
- Meglévő Laravel-fióknál a régi jelszó ellenőrzése megelőzi a Firebase-fiók létrehozását.
- A Firebase UID és ID token bekerül a Laravel login kérésbe.
- Kijelentkezéskor és 401-es munkamenethibánál a Firebase munkamenet is törlődik.
- Az új felhasználó profilkiegészítése nem blokkolja a belépést; a telefonszám és a fizetési adatok az első fizetés előtti folyamatba kerülnek.
- Push értesítési engedélykérés ebben a verzióban még nincs bekapcsolva, hogy a belépési teszt külön kezelhető legyen.
- Apple és Facebook belépés ebben az Android első ütemben még nincs aktiválva.

## Verzió

- App: `1.0.20+29`
- Debug logger: `1.0.20+29`
