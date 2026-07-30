# UTASAPP 1.0.23+32

## Belépés és regisztráció

- Az e-mailes Belépés és Regisztráció most két külön, egyértelmű fül.
- A Belépés kizárólag meglévő Firebase-fiókot fogad el.
- A Regisztráció külön fiókot hoz létre, jelszó-megerősítést kér, és magyar nyelvű Firebase e-mail-ellenőrzést küld.
- Google-fióknál az első belépés továbbra is automatikus regisztráció, a későbbi alkalmak belépések.

## Backend fiók és e-mail

- Az új backend patch mind Google-, mind e-mailes első Laravel-fióklétrehozás után egyszeri, márkázott HTML üdvözlő levelet küld.
- A levélküldés hibája nem blokkolja a belépést; a rendszer a következő belépésnél újrapróbálja.

## Kijelentkezés

- A profilból történő kijelentkezés többé nem marad bent `failed` válasz miatt.
- A szerveres token-visszavonás best-effort, a helyi és Firebase munkamenet mindig törlődik.
- Új stabil backend végpont: `POST /api/user/logout-safe`.

## Bejelentkező kép

- A bejelentkező képernyő a megadott `soforszoglalat.png` képet tölti be.
- Hálózati hiba esetén a korábbi beépített kép marad biztonságos tartalék.
