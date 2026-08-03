# Veszprémi Taxi sofőrapp 1.0.8+14

- Az Android Google Maps kulcs már nem szöveges helykitöltő: a build a `GOOGLE_MAPS_API_KEY` Codemagic környezeti változóból vagy `android/local.properties` fájlból tölti be.
- A sofőr főtérkép stabil Veszprém kezdőpozíciót és egyetlen tartós térképpéldányt használ.
- A térképvezérlő nem próbálható többször befejezni.
- A sikeres munkába állás állapota helyben megmarad akkor is, ha a hibás `/api/driver/profile` kérés 500 választ ad.
- A helyzetfrissítés a helyben hitelesített online állapotot is elfogadja.
- A valós idejű `new.ride.request` eseményt már nem blokkolja a hiányzó/hibás profilmodell `is_online` mezője.
- A korábbi VAP arculat, belépési logó és munkába állási javítások megmaradtak.

## Codemagic
A workflow környezetében legyen elérhető a már az utasappnál használt `GOOGLE_MAPS_API_KEY` változó. A kulcs értékét a forrás nem tartalmazza.
