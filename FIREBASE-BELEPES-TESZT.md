# Firebase belépés teszt – UTASAPP 1.0.20+29

## Telepítés

A korábbi UTASAPP felülírható. Az első indításkor a korábbi Laravel munkamenet nem elég: Firebase felhasználó nélkül a program a belépési oldalra irányít.

## Teszt 1 – meglévő e-mailes utas

1. Add meg a meglévő Laravel e-mail-címet és jelszót.
2. Az app előbb a Laravel jelszót ellenőrzi.
3. Ha a Firebase-fiók még nem létezik, létrehozza ugyanazzal a jelszóval.
4. Siker után a főoldal nyílik meg.
5. Zárd be teljesen az appot, majd nyisd meg újra: belépve kell maradnia.

## Teszt 2 – új e-mailes utas

1. Adj meg egy még nem használt e-mail-címet és legalább 6 karakteres jelszót.
2. A Firebase-fiók és a Laravel utas létrejön.
3. A főoldal megnyílik.
4. A megerősítő e-mail megérkezhet, de a belépést nem blokkolja.

## Teszt 3 – Google

1. Jelentkezz ki.
2. Nyomd meg a „Folytatás Google-fiókkal” gombot.
3. Válassz Google-fiókot.
4. Siker után a főoldal nyílik meg.
5. Újraindítás után belépve kell maradnia.

## Teszt 4 – kötelező belépés

1. Jelentkezz ki.
2. Zárd be és nyisd meg az appot.
3. Nem jelenhet meg térkép, címkeresés vagy rendelési képernyő a belépés előtt.

## Naplóban elvárt verzió

`app_version: 1.0.20+29`
