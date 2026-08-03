# SOFŐRAPP 1.0.26+32 – build javítás

- Javítva a `lib/feature/home/pages/otp_verify_screen.dart` fordítási hibája.
- Az `inputFormatters` lista nem lehetett `const`, mert a `FilteringTextInputFormatter.digitsOnly` és a `LengthLimitingTextInputFormatter(6)` nem konstans kifejezések.
- A Blackview tablet nézet, az egységesített belső navigáció, az OTP-képernyő, az utasnév, a törléskezelés és a fizetve gomb változatlanul benne maradt.
- Verzió: `1.0.26+32`.
