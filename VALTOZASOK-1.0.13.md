# Veszprémi Taxi Sofőr 1.0.13+19

## Fuvar elfogadása

- Az ajánlati panel csak sikeres `update-status` válasz után tűnik el.
- Szerverhiba esetén az ajánlat a képernyőn marad, ezért nem lesz látszólag elveszett fuvar.
- A 1.0.12 állapot-helyreállításai megmaradtak.

## Távolság és aktív fuvar

- A sofőr–utas távolságot az app az aktuális GPS-helyből újraszámolja.
- Az elfogadott fuvar képernyőjén a Google útvonal valós távolsága és ideje jelenik meg.
- A korábbi, pending-offer válaszból származó elavult 757/1400 km-es érték nem kerül kiírásra.
- Útvonal-válasz nélküli helyzetben biztonságos `Távolság számítása…` állapot látszik.

## Térképes ikonok

- Helyi, stabil sofőrautó-marker került be.
- Külön zöld felvételi és narancs célmarker került be.
- A távoli fuvartípus-ikon nem írhatja felül a sofőr markert.
- A nehezen felismerhető navigációs és időzítő ikon lecserélve.

## Indítás és alkalmazásikon

- A Flutter nyitókép minimum 2 másodpercig látszik.
- A régi eTaxi Driver WEBP launcher ikonok eltávolítva.
- Minden Android sűrűséghez VAP Driver launcher ikon készült.
- Verzió: `1.0.13+19`.

## Kapcsolódó szerverhiba

A 2026-07-29-i tesztben a fuvar elfogadása adatbázisban sikerült, de a válasz 500 lett, mert a `BookingStatusChanged` esemény egy nem létező `auto_arriving_scheduled_at` mezőt olvasott. Emiatt a sofőrapp visszatért a főoldalra, majd ugyanaz a már elfogadott fuvar később aktív rendelésként újra megjelent.

A mellékelt külön szerverjavító létrehozza a hiányzó mezőt, kijavítja az üres gyári migrációt, és megakadályozza, hogy egy broadcast-hiba sikeres státuszmentés után 500-as választ okozzon.
