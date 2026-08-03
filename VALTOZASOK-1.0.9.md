# Veszprémi Taxi sofőrapp 1.0.9+15

- A tesztsofőr belépési mezői automatikusan ki vannak töltve.
- A Pusher kapcsolat már megvárja a hivatalos kapcsolatfelépítési eseményt, és csak utána iratkozik fel a `drivers.all` csatornára.
- Javítva a `pusher:connection_established` eseménynév.
- Hozzáadva a Pusher ping/pong kezelés és a stabil újracsatlakozás.
- A socket stream újracsatlakozáskor nem szakad le a meglévő figyelőről.
- A fuvar csak a célzott sofőrazonosító egyezése és online állapot mellett jelenik meg.
- Verzió: 1.0.9+15.

Megjegyzés: a beépített tesztbelépést éles kiadás előtt ki kell kapcsolni vagy dart-define értékekkel felülírni.
