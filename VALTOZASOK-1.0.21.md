# Veszprémi Taxi Sofőr 1.0.21+27 – nagy P0 javítócsomag

- Az utazási kód először a dedikált `/driver/bookings/match-otp` végponton ellenőrződik.
- Sikeres kódellenőrzés után a fuvar `started` állapotba lép; a régi, hibás közvetlen OTP-validáció nem fut le újra.
- A 422 válaszok teljes `errors` mezője bekerül a célzott debugnaplóba.
- A Routes API útvonalrajzolás mellé valódi Directions API fallback került, saját polyline-dekódolással.
- A belső útvonal vastagabb, jól látható VAP-sárga vonalat kapott.
- A profilból érkező régi `accepted/arrived` fuvar 90 perc után nem nyílhat meg újra automatikusan.
- A profilbeli booking ID és a visszaadott fuvar ID egyezése kötelező az automatikus visszaállításhoz.
- A chat a backend `is_from_me` mezőjét is figyelembe veszi, és naplózza a ténylegesen feldolgozott üzenetszámot.
- A Codemagic memóriajavítások és a meglévő 1.0.19-es chat/polling javítások megmaradtak.

- Az OTP ellenőrzése utáni státuszváltás már nem küld üres vagy másodszor validálandó `otp` mezőt.
- A debug kliensverzió frissült `1.0.21+27` értékre, így a közös JSONL-ben egyértelműen felismerhető.
- A Codemagic Flutter-verzió `3.41.9` értékre rögzített; a meglévő Codemagic pre-build kulcsbeírás változatlanul használható.
- A magyar várakozási szövegből kikerült a rúpiás gyári példa.
