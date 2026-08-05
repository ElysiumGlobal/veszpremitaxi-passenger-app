# Veszprémi Taxi Passenger 1.0.27+36

Célzott fuvarvégi és ETA-integrációs javítás a hiteles 1.0.25+34 (`a0231f8`) alaphoz.

- A `completed` fuvar fizetési státusztól függetlenül terminális.
- A profile polling leáll terminális állapotnál.
- Elveszett completed eseménynél a `started` állapotból két egymást követő, pontos szerveres pointerfelszabadítás lezárja a fuvart.
- A profilfrissítés nem törli ki versenyhelyzetben a `started` lokális állapotot, amíg a trip polling befejezi a lezárást.
- A ratinghez szükséges bookingmodell a rating folyamat végéig megmarad.
- ETA UI-változtatás nem szükséges; az ETA mezőket a kapcsolódó backend patch adja vissza.

Nem módosítja az útvonalválasztást, a modalnyitást vagy a rating célpontját.
