# Veszprémi Taxi Sofőr 1.0.17+23

- Javítva a debug buildet megállító Dart importütközés.
- A `dart:math` import csak a `Random` osztályt hozza be, ezért nem ütközik a `dart:developer` `log()` függvényével.
- A flow-debug működése és a backend végpont változatlan.
