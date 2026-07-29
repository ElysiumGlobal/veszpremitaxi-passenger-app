# Veszprémi Taxi Utas 1.0.12+21 – megbízható utasoldali debug

## Miért készült

A 2026-07-29-i hozzáférési napló bizonyította, hogy az utasapp elérte a debuggyűjtőt, de a régi szerveroldali gyűjtő `role_id=3` esetén 403 választ adott. A szerveren már a `2026-07-29-role2-role3-v2` gyűjtő fut, ezért ez a forrás a kliensoldali kézbesítést teszi robusztussá.

## Javítások

- Verzió: `1.0.12+21`, hogy a következő logban egyértelműen elkülönüljön a régi APK-tól.
- A belépés előtti debugesemények nem vesznek el tokenhiány miatt.
- A token és a felhasználóazonosító mentése meg van várva a navigáció előtt.
- Sikeres tokenmentés után az app azonnal újraindítja a debugküldést.
- Hálózati hiba, 401/403, 429 vagy 5xx esetén az esemény a sorban marad és később újrapróbálódik.
- Hibás payload / hibás végpont esetén a hibás rekord nem akasztja meg a teljes sort.
- A kliens minden debugkérésben elküldi az `X-VTaxi-Debug-Client: 1.0.12+21` fejlécet.
- A csomagban lévő backend gyűjtő pontosan ugyanaz a fájl, amelynek selftestje ezt adja:
  - `collector_version: 2026-07-29-role2-role3-v2`
  - driver role: `2`
  - passenger role: `3`
- A korábbi socket hiba javítása megmaradt: a socket `data` mező String és Map formátumot egyaránt kezel, így a régi `_Map<String, dynamic> is not a subtype of String` kivétel ezen a ponton nem térhet vissza.
- Codemagic Flutter verzió rögzítve: `3.41.9`.

## Tesztmenet

1. A szerveroldali debugnézetben ürítsd a naplót.
2. Építsd meg ezt a forrást Codemagicban az `android-debug` workflow-val.
3. Telepítsd tisztán az APK-t.
4. Jelentkezz be az utas tesztfiókkal.
5. Adj meg indulási pontot és úti célt.
6. Válassz autót, majd véglegesítsd a rendelést.
7. Hagyd nyitva a sofőrkereső képernyőt legalább 30 másodpercig.
8. Töltsd le a JSONL naplót a szerveroldali gyűjtőből.

A jó naplóban az `app_version` értéke `1.0.12+21`, az `actor_role` értéke `passenger`, és szerepelnie kell legalább a `passenger_auth_token_saved`, `booking_estimate_requested`, `booking_create_success`, `booking_confirm_response` és `search_driver_screen_opened` eseményeknek.
