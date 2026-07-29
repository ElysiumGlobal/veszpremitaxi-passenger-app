# Veszprémi Taxi Utas 1.0.10+19

- Javítva a Codemagic buildet blokkoló hibás debug mezőhivatkozás.
- A booking estimate naplózása a modellben ténylegesen létező `distance` és `duration` mezőket használja.
- Ha ezek hiányoznak, a `ride_type_estimate` távolság- és időtartamadataira vált vissza.
- Egyéb alkalmazáslogika nem változott az 1.0.9+18 verzióhoz képest.
