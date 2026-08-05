# Veszprémi Taxi Passenger 1.0.28+37 – ride-end final candidate

Alap: Passenger 1.0.27+36 integration fix.

Célzott kiegészítések:

- A szerveres pointerfelszabadítást csak két egymást követő, pontosan üres profile-válasz igazolhatja.
- Az általános profile-inkonzisztencia számláló nem indíthat téves completiont.
- Visszakerült a hiányzó `android/gradle/wrapper/gradle-wrapper.jar` a Codemagic/Gradle buildhez.
- A `backend-tools/` mappa kikerült a mobil release-forrásból.

A completion továbbra is fizetési státusztól függetlenül terminális az utasappban, és a ratinghez szükséges bookingmodell megmarad a rating folyamat végéig.
