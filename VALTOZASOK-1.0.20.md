# 1.0.20+26 – Codemagic memóriajavítás

- A Gradle build párhuzamos végrehajtása kikapcsolva.
- A Gradle worker száma 1-re korlátozva.
- A Gradle heap 4 GB, a Kotlin daemon heap 1,5 GB.
- A szükségtelen Jetifier kikapcsolva, mert a projekt AndroidX alapú.
- A debug APK csak ARM64 célra készül, ami megfelel a Blackview Tab 60 Pro és a BrowserStack teszttablet architektúrájának.
- A build parancs a már lefuttatott `flutter pub get` után `--no-pub` kapcsolót használ.

Ez a verzió nem változtatja meg az alkalmazás üzleti logikáját vagy felületét; kizárólag a Codemagic build stabilitását javítja.
