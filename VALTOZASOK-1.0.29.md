# SOFŐRAPP 1.0.29+35

## Készpénzes fizetés

- A „Készpénz átvéve” gomb már valódi backend API-kérést küld.
- A backend patch a befejezett készpénzes rendelést `payment_status=paid` állapotba teszi.
- Rögzíti a viteldíj készpénzes összegét és a külön készpénzes borravalót.
- Borravaló: nincs / 500 Ft / 1000 Ft / egyedi összeg.
- A fizetési képernyő csak sikeres `paid` válasz után enged tovább.
- A régi, tranzakció nélküli ál-fizetési továbblépés kikerült.

## Értékelés

- A sofőr már az utast értékeli, nem saját magát.
- A lezárt fuvar és az utas adatai az értékelés végéig megmaradnak.
- Értékelés mentése vagy kihagyása után tisztul a helyi fuvarállapot és nyílik a főképernyő.

## OTP-kódbevitel

- Egyetlen stabil beviteli mező maradt.
- A fókuszvesztést a képernyő azonnal érzékeli és helyreállítja.
- A billentyűzetet fókusz-visszaállításkor újra megnyitja.
- 700 ms-os fókuszőr figyeli a mezőt, ezért gépelési szünet után sem szabad kilépnie.
- Nincs kurzor-újraírás minden karakter után.
- A fókuszvesztés és helyreállítás bekerült a debug logba.

## Célkészülék

Blackview Tab 60 Pro, 1280×800, fekvő nézet.
