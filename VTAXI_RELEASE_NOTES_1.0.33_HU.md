# Veszprémi Taxi Sofőr 1.0.33+39

## Javítások

- Megszűnt a kötelező fekvő tájolás. Telefonon és tableten is engedélyezett az elforgatás.
- Új, reszponzív sofőr-főképernyő készült térkép nélkül.
- A belépőképernyő telefonon és tableten is reszponzív, az 5 fix sofőr + 8 számjegyű kód rendszer változatlan.
- Az alkalmazás háttérből visszatérve helyreállítja a szolgálati állapotot, a kapcsolatot, a GPS-t és az ajánlatfigyelést.
- A pending-offer lekérés online heartbeatet is küld, ezért a szerver hibás offline állapota automatikusan javítható.
- A PIN-es belépés elküldi a tényleges FCM eszköztokent. Firebase Auth továbbra sincs a sofőrbelépésben.
- Beérkező fuvarhoz magas prioritású helyi értesítés, hang és rezgés tartozik.
- A profil végpont átmeneti hibája nem állítja le a fuvarajánlatok figyelését.
- Régi helyi fuvarállapot nem blokkolhat új ajánlatot.
- Elfogadás csak ténylegesen kirajzolt panelről, valódi érintés és választott ETA után történhet.
- Tartós, teljes körű debugnapló megmaradt.

## Build

Codemagic workflow: `android-debug`

Elvárt verzió: `1.0.33+39`
