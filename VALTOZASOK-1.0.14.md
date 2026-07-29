# Veszprémi Taxi Utas 1.0.14+23

## Buildjavítás

- Eltávolítva a nem támogatott `showToast: false` név szerinti paraméter a `HomeService.cancelRide()` API-hívásából.
- Az `Api.post()` jelenlegi függvényaláírása változatlan: `url`, `queryData`, `bodyData`, `header`.
- Az 1.0.13 P0 módosításai változatlanul megmaradtak.

## Érintett fájlok

- `lib/feature/home/service/home_service.dart`
- `pubspec.yaml`
