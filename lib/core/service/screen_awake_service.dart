import 'package:flutter/services.dart';

class ScreenAwakeService {
  ScreenAwakeService._();

  static const MethodChannel _channel = MethodChannel(
    'hu.veszpremitaxi.passenger/screen_awake',
  );

  static bool _requested = false;

  static Future<void> setKeepAwake(bool keepAwake) async {
    if (_requested == keepAwake) return;
    try {
      await _channel.invokeMethod<void>('setKeepAwake', keepAwake);
      _requested = keepAwake;
    } catch (_) {
      // A képernyő-ébrentartás kényelmi funkció: hibája nem állíthatja meg a fuvart.
    }
  }
}
