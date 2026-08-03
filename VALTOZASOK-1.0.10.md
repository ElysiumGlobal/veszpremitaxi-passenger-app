# Veszprémi Taxi Driver 1.0.10+16

- A tesztbelépési adatok továbbra is előre ki vannak töltve.
- Új, 3 másodperces HTTP polling fallback érkezett a fuvarajánlatokhoz.
- A fuvarajánlat akkor is megjelenik, ha a Pusher broadcast nincs beállítva.
- Csak online, aktív járművel rendelkező sofőr kérhet ajánlatot.
- Az elfogadás továbbra is kézi, az existing update-status végponton történik.
- Elavult current_booking_id nem blokkolja az új ajánlatot.
