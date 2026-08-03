# Veszprémi Taxi Sofőr 1.0.22+28

## Codemagic fordítási javítás

- Eltávolítva a `showToast: false` opcionális név szerinti argumentum minden `Api().get()` és `Api().post()` hívásból.
- Ez megszünteti a Codemagic által jelzett `No named parameter with the name 'showToast'` fordítási hibát.
- A 1.0.21 P0 funkciói változatlanul megmaradtak: OTP-ellenőrzés, belső útvonal, stale booking védelem, chat és részletes debug.
