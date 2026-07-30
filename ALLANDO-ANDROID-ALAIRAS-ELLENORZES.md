# Allando Android alairas ellenorzese

A Codemagic build utan az APK tanusitvanyanak SHA-1 erteke pontosan ez legyen:

`F3:B7:03:B9:9A:07:33:EF:F3:E1:C0:13:88:98:7A:CC:7D:0C:E2:EF`

Ellenorzes a build logban vagy helyben:

```sh
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-debug.apk
```

A repoba tilos feltolteni:

- `.jks` vagy `.keystore` fajlt
- `android/key.properties` fajlt
- keystore vagy key jelszavakat
