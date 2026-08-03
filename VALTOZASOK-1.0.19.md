# Veszpremi Taxi Sofor 1.0.19+25

## Uj fuvarajanlat megbizhatosaga

- A 2026-07-29-i celzott naplo alapjan a 33-as fuvar lemondasa HTTP 200 valasszal sikerult, a navigacios kepernyo bezarult, de az elozo helyi `accepted` allapot kepes volt bent maradni.
- A terminalis allapotok (lemondas es utasoldali lemondas) most torlik a helyi aktiv fuvarmodellt, a helyi `current_booking_id` erteket, az idozitoket es az elozo ajanlat azonositojat.
- A pending-offer ellenorzes 3 masodperces fallbackkel fut, appindulaskor, profil-szinkron utan, munkaba allaskor es hatterbol visszatereskor azonnali kenyszeritett ellenorzest is kap.
- Egy onmagaban beragadt profilbeli `current_booking_id` tobbe nem allitja le vegleg az ajanlatlekerest; a backend tovabbra is donthet ugy, hogy nincs kiadhato ajanlat.
- Az uj ajanlat a menukbol is visszaviszi a sofort a fokepernyore, es ugyanaz a visszautasitott vagy sikertelenul elfogadott ajanlat ujra megjelenhet.
- A debug kulon naplozza az ellenorzes inditasat, kihagyasanak okat, HTTP-valaszat, az ajanlat megjeleniteset es az elfogadas eredmenyet.

## Lebego aktiv fuvarpanel

A navigacios terkep tetejen folyamatosan lathato panel jelenik meg:

- aktualis fuvarfazis;
- utas neve;
- aktualis felveteli vagy celcim;
- tavolsag az utasig vagy a celig;
- teljes fuvar tavolsaga;
- Hivas, Chat es Navigacio gomb.

A teljes fuvar tavolsaga kezeli a meter/km elterest. Nyilvanvaloan hibas API-adatnal a felveteli es celkoordinatakbol biztonsagos kozelitest mutat `~` jellel. Ez csak kijelzes; a dijszamitas tovabbra is a backend feladata.

## Chat

- Az uzenetkuldes a Laravel `POST /chat/send` vegponton keresztul tortenik, igy az uzenet adatbazisba kerul.
- Betoltes a `GET /chat/list?booking_id=...` vegpontrol.
- Olvasottnak jeloles bekotve.
- Saját, meg torolheto uzenet torlese bekotve.
- WebSocket mellett 4 masodperces HTTP fallback fut, ezert a chat socket-hiba eseten is frissul.
- A chat nyitasa, betoltese, kuldese, torlese es socket-esemenyei bekerulnek a celzott flow debugba, uzenetszoveg nelkul.

## Magyaritas

- A teljes angol lokalizacios szotar 440 kulcsa magyar felulirast kapott.
- Az alkalmazas alapertelmezett es tartalek nyelve `hu_HU`.
- A fuvartortenet, fuvarreszletek, statuszok, fizetesi modok, lemondasi okok, tavolsagok, idotartamok es HUF osszegek magyar megjelenitest kaptak.
- Tovabbi kozvetlen angol feliratok magyaritva lettek a profil, fizetes, tamogatas es bonusz kepernyokon.
- A gyakori halozati hiba-uzenetek magyarul jelennek meg.

## Biztonsagi naplozas

- A hozzaferesi token es a teljes Authorization header tobbe nem kerul konzolnaploba.
- A nyers push payload es az utas teljes adatobjektuma sem kerul kiirasra.

## Ellenorzes

- 166 Dart fajl zarojel- es szovegliteral-szerkezete ellenorizve.
- A `pubspec.yaml` ervenyes, verzio: `1.0.19+25`.
- A magyar szotar lefedi az osszes angol lokalizacios kulcsot, duplikacio nelkul.
- Helyi Flutter SDK nem allt rendelkezesre, ezert a vegleges forditasi ellenorzes a Codemagic debug build.
