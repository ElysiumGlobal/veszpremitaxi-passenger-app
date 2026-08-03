# UTASAPP 1.0.22+31

## Firebase -> Laravel utasfiok

- Uj backend vegpont: `POST user/firebase-session`.
- A backend ellenorzi a Firebase ID token alairasat es projektazonositojat.
- Google vagy ellenorzott e-mailes belepes utan az utas azonnal letrejon/osszekapcsolodik a Laravel `users` tablaban (`role_id=3`).
- A meglovo Laravel belepteto adja vissza a megszokott API tokent.
- A Firebase UID, provider es ellenorzesi ido kulon users oszlopokba kerul.

## E-mail ellenorzes

- Uj e-mailes fioknal megerosito level megy ki.
- A felhasznalo addig nem jut be az appba, amig a Firebase szerint az e-mail-cim nincs megerositve.
- Megerosites utan uj belepessel folytathato a folyamat.

## Kotelezo telefonszam

- A Laravel utasfiok mar a Firebase belepeskor letrejon, nem kell megvarni az elso rendelest.
- Telefonszam nelkul kotelezo profilkapu nyilik meg.
- Uj backend vegpont: `POST user/complete-phone` Bearer tokennel.
- A telefonszam elmentese utan nyilik meg a terkep es a rendelesi felulet.
- App-ujrainditas utan sem kerulheto meg a telefonszam-kapu.

## Backend telepito

`backend-tools/vtaxi-firebase-passenger-backend-patch-20260730.php`

Feltoltes a Laravel `public/` mappajaba, majd CHECK es INSTALL.
