# Veszprémi Taxi Sofőr 1.0.18+24

- Az utas felvételi pontja GPS nélkül is azonnal megjelenik a térképen.
- A marker információs buborékában látható az utas neve.
- A Navigate gomb valódi Google Maps navigációt indít.
- A Mark Reached nem kér újra háttér-helyengedélyt, ezért nem fagy végtelen töltésbe.
- A Mark Reached 10 másodperces GPS-időkorlátot és részletes debug eseményeket kapott.
- A távolság egyértelműen külön jelzi az utasig és a teljes fuvarra vonatkozó értéket.
- Directions API tiltás esetén a rendszer nem küld végtelen hibás kéréseket, hanem helyi távolságbecslésre vált.
