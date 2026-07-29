# Veszprémi Taxi Utas 1.0.13+22 – nagy P0 és vizuális javítócsomag

- A profilból kapott `current_booking` csak akkor nyílhat meg automatikusan, ha a `data.current_booking_id` ugyanarra a bookingra mutat.
- A régi `searching` fuvar 30 perc, az `accepted/arrived` fuvar 90 perc után nem állítható vissza automatikusan.
- A törlés idempotens: a „Booking Already Canceled” választ sikeres helyi takarításként kezeli.
- A jelenlegi ismert backend mass-assignment hiba után a kliens felismeri a részben végrehajtott lemondást, és nem tartja nyitva a régi fuvart.
- Lemondáskor törlődik a helyi booking ID, fuvarmodell, ár-cache és aktív képernyőállapot.
- Az indulási pont ellenőrző térképe 17,5-ös zoommal közvetlenül a kiválasztott pontra közelít.
- A gyári piros Google pin helyett saját VAP pickup marker jelenik meg.
- A pickup, destination és sofőrmarker a sofőrapp egységes sárga VAP ikonrendszerét használja.
- A járműkártya hibás backendkép esetén nem szürke placeholdert, hanem saját taxiikont mutat.
- A `NormálVeszprém` típusnév megjelenítése `Normál` formára tisztul.
- A kijelölt taxi marker 900 ms alatt odagurul az új GPS-pontra, és a menetirányba fordul; nem teleportál.
- A kamera nem követi erőszakosan minden GPS-frissítésnél a markert.
- A chat az `is_from_me` mezőt is figyelembe veszi, és naplózza a tényleges üzenetszámot.
- Az 1.0.12 megbízható utasoldali debug változatlanul megmaradt.

- A debug kliensverzió frissült `1.0.13+22` értékre.
- A látható `E-Taxi`, Bhuj és indiai mintacímek Veszprémi Taxi/Veszprém szövegekre cserélődtek.
- A meglévő Codemagic pre-build script által létrehozott `assets/.env` kulcskezelés változatlanul megmarad.
