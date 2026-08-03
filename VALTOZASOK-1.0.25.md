# Veszprémi Taxi SOFŐRAPP 1.0.25+31

## Blackview Tab 60 Pro

- A céleszköz továbbra is kizárólag a Blackview Tab 60 Pro, 1280x800, fekvő nézet.
- Az OTP képernyő fix, nagy, egymezős 6 számjegyű bevitelt kapott; a billentyűzet nem nyomhatja szét a felületet.
- Tablet nézetben egyetlen fő fuvarpanel marad, a duplikált felső kártya nem jelenik meg.

## Fuvarfolyamat

- Elfogadott fuvarnál a belső navigáció az utashoz vezet.
- Megérkezés után az útvonal és az instrukciók megállnak az OTP elfogadásáig.
- Sikeres OTP után a belső navigáció az úti célra vált.
- A külső Google Térkép megnyitása megszűnt; minden navigációs gomb a beépített térképet fókuszálja.
- Az utas neve megjelenik a felvételi marker információs ablakában.

## Lemondás és lezárás

- Az aktív fuvar szerverállapotát a SOFŐRAPP időszakosan újraellenőrzi.
- Utas általi törlésnél a helyi aktív fuvar, navigáció és ajánlati blokkolás megszűnik.
- A többféle régi és új törlési socket-esemény kezelve van.
- Befejezett fuvarnál a helyi aktív állapot azonnal törlődik.

## Fizetés tesztelése

- A pénztárképernyőn mindig elérhető az „A rendelés fizetve” gomb.
- Valódi tranzakcióazonosítónál a meglévő backend fizetési végpont fut.
- Fizetési szolgáltató nélkül a gomb csak a tesztfolyamatot zárja le helyben; valódi pénzügyi státuszt nem hamisít a backendben.
