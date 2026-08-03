# Veszprémi Taxi UTASAPP 1.0.18+27

## Buildjavítás

- A `HomeController.socketData()` most `Future<void>` visszatérési típusú és `async`.
- Így a fuvar befejezésekor az utazási előzmények frissítése szabályosan várható meg az `await` kulcsszóval.
- Javítva a Codemagic fordítási hiba: `await can only be used in async or async* methods`.
- Az 1.0.17 összes funkcionális javítása változatlanul megmaradt.
