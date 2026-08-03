# Veszpremi Taxi utasalkalmazas 1.0.9+18

## P0 fuvarfelveteli teszt

- A profil csak `searching`, `accepted`, `arrived` vagy `started` foglalast nyit meg automatikusan.
- A `cancelled`, `expired` es `completed` foglalas helyi allapota torlodik, ezert a regi Utazas reszletei ablak nem ter vissza minden inditaskor.
- Harommasodperces profilalapu statusz polling maradt a WebSocket tartalekakent.
- Az utazasi kod a sofor erkezese utan feltuno magyar szoveggel jelenik meg.

## Utasoldali flow debug

- Uj `VTAXI_PASSENGER_FLOW` esemenyek a BrowserStack Logcatban.
- Naplozott pontok: profil, stale booking torles, becsles, booking letrehozas, megerosites, statuszvaltas, soforpozicio es chat.
- Token, telefonszam, nev, cim es teljes koordinata nem kerul a telemetriaba.

## Chat

- Az uzenet a Laravel `POST /api/chat/send` vegpontjan mentodik.
- Negymasodperces HTTP frissites WebSocket tartalekkent.
- Olvasottsag es sajat friss uzenet torlese.

## Megjelenes

- A harom onboarding kep uj V3 allapot miatt egyszer ujra megjelenik.
- Az elso betoltokepernyo 2,8 masodpercig, a teljes splash legalabb 5 masodpercig lathato.
- Magyar, markaszines also navigacio: Fooldal, Utazasok, Tarca, Profil.
- Kulon felveteli es celmarker; a `Coming Soon` felirat eltavolitva.
- HUF kenyszerites az alkalmazas beallitasaban.

## Build

- Codemagic ARM64 debug workflow.
- Egy Gradle worker, parhuzamos build es Jetifier kikapcsolva a Java heap hiba megelozesere.
