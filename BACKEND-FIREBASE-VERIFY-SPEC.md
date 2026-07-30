# Következő backend biztonsági lépés

Az UTASAPP a meglévő `user/login/password` végpontra már elküldi:

- `firebase_uid`
- `firebase_id_token`
- `auth_provider`
- `email`
- `device_token`

A Laravel következő biztonsági frissítésében a `firebase_id_token` szerveroldali ellenőrzése szükséges a Veszprémi Taxi Firebase projekt nyilvános kulcsaival / Firebase Admin SDK-val. Az ellenőrzött token `uid`, `email` és provider adatait kell a Laravel utashoz kötni. A kliens által küldött `firebase_uid` önmagában nem tekinthető hitelesnek.
