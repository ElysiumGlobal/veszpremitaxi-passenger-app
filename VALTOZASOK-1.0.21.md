# UTASAPP 1.0.21+30

## Allando Android alairas

- A debug es release Android buildek Codemagicben ugyanazt az allando Veszpremi Taxi Utas kulcsot hasznaljak.
- Tamogatott Codemagic valtozok: `CM_KEYSTORE_PATH`, `CM_KEYSTORE_PASSWORD`, `CM_KEY_ALIAS`, `CM_KEY_PASSWORD`.
- A Flutter workflow editor altal generalt `android/key.properties` is tamogatott.
- A keystore es a jelszavak nem kerultek a forraskodba.
- Friss Firebase `google-services.json` kerult be, benne az allando SHA-1 OAuth klienssel.

## Allando Firebase fingerprint

- SHA-1: `F3:B7:03:B9:9A:07:33:EF:F3:E1:C0:13:88:98:7A:CC:7D:0C:E2:EF`
- SHA-256: `AB:D0:CF:00:0C:AF:AC:6A:EC:64:D4:C1:E0:AE:31:39:DB:85:B4:30:8F:C3:1D:A7:68:8E:F6:82:8F:08:1A:76`

## Telepitesi megjegyzes

A korabbi, mas debug kulccsal alairt UTASAPP nem frissitheto kozvetlenul erre. Az elso allando kulcsos telepites elott a regi tesztappot el kell tavolitani. Ettol kezdve az uj buildek mar egymasra telepithetok.
