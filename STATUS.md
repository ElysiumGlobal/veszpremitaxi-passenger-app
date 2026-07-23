# Veszprémi Taxi Android utasapp – leállított átadási állapot

## Fontos minősítés

Az APK-mérföldkő **nincs készre jelentve**. A buildfolyamat leállt, újabb build nem fut, és további SDK/NDK/CMake/proxy/repository módosítás nem történt az átadás készítése közben.

## Meddig jutott a build

- A legutolsó rögzített Gradle-futás `:app:assembleDebug` feladata sikeresen befejeződött: `BUILD SUCCESSFUL in 25s`.
- Létrejött a debug APK két, byte szerint azonos példánya:
  - `build/app/outputs/flutter-apk/app-debug.apk`
  - `build/app/outputs/apk/debug/app-debug.apk`
- Méret: `167 759 995` byte.
- SHA-256: `6e696f2f9d1f31b2c1ac4f2b885a0c6d1ff79809f59ae1f1f88ab480bea3aab1`.
- Csomagnév: `hu.veszpremitaxi.passenger`.
- Verzió: `1.0.1` (`versionCode 10`).
- `minSdk 24`, `targetSdk 36`, `compileSdk 36`.

## Amit ténylegesen ellenőriztünk

- Az APK ZIP-szerkezete hibátlan (`unzip -t`).
- Az APK `zipalign` ellenőrzése sikeres.
- Az APK v2 debug-aláírása érvényes; egy aláíró van (`CN=Android Debug`).
- A két APK-példány byte szerint azonos.
- A manifest csomagneve, verziója és SDK-értékei kiolvashatók.

## Ami még hiányzik az APK-mérföldkőhöz

- APK tényleges telepítése Android telefonra vagy emulátorra.
- Az alkalmazás elindítása és induláskori összeomlás kizárása.
- A működő Laravel backend elérhetőségének ellenőrzése az appból.
- A Laravel-alapú OTP/belépési folyamat végigtesztelése.
- A Google Maps végleges API-kulcsának és Cloud-korlátozásainak későbbi beállítása. A jelenlegi lokális buildben a Maps-kulcs üres.

## Pontos utolsó hiba

A legutolsó **sikertelen** buildkísérlet hibája a sikeres `assembleDebug` előtt:

```text
Execution failed for task ':app:configureCMakeDebug[arm64-v8a]'.
The CMAKE_C_COMPILER:
  .../ndk/27.0.12077973/toolchains/llvm/prebuilt/linux-x86_64/bin/clang
is not a full path to an existing compiler tool.

The CMAKE_CXX_COMPILER:
  .../ndk/27.0.12077973/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++
is not a full path to an existing compiler tool.
```

Gyökérok: a környezet az NDK `clang` és `clang++` szimbolikus linkjeit használhatatlan, `/rsyncd-munged/...` célra alakította. A következő futás egy külön lokális, azonos NDK 27.0.12077973 példányt használt, amelyben ez a két bejegyzés valódi fájl volt; ez a futás sikeres lett. A legutolsó tényleges buildben ezért már nem volt hiba.

## Forrásállapot

A feltöltött `VESZPREMITAXI-UTAS-PORTABLE-CHECKPOINT-v1(2).zip` és a jelenlegi projekt byte szerinti összehasonlítása alapján az alkalmazás forrása és tartós projektkonfigurációja ebben a folytatásban nem változott. Csak build által generált, lokális vagy átadási állományok keletkeztek; ezeket a `deliverables/MODIFIED-PROJECT-FILES.md` és `deliverables/ENVIRONMENT-CHANGES.md` fájl részletezi.

