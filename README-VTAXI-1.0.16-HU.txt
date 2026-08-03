VESZPREMI TAXI SOFOR 1.0.16+22

Teljes Flutter forrasprojekt, nem patch.

Tartalmazza:
- a 1.0.13 ikon-, splash-, marker- es navigacios javitasait;
- celzott, nem blokkoló flow debugot az Elfogadom, navigacios kepernyo, GoogleMap, GPS, polyline es Mark Reached lepesekhez;
- a debug nem a routes/api.php fajlt hasznalja, hanem a kozvetlen, hitelesitett publikus vegpontot:
  https://api.veszpremitaxi.hu/vtaxi-driver-flow-debug-29c7.php

Szukseges backend telepito:
vtaxi-driver-flow-debug-29c7.php

A debug nem kuld tokent, telefonszamot, nevet, e-mailt, cimet vagy profilkepet.
A debug hibaja nem blokkolhatja a fuvarfolyamatot.
