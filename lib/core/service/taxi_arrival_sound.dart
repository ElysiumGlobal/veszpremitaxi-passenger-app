import 'dart:typed_data';

import 'package:flutter/services.dart';

class TaxiArrivalSound {
  TaxiArrivalSound._();

  static const MethodChannel _channel = MethodChannel(
    'hu.veszpremitaxi.passenger/arrival_sound',
  );
  static const String _assetPath = 'assets/sounds/taxi_arrived_whistle.wav';

  static Uint8List? _cachedAudioBytes;

  static Future<bool> play() async {
    try {
      final Uint8List audioBytes = _cachedAudioBytes ??=
          await _loadAudioBytes();
      if (audioBytes.isEmpty) {
        return false;
      }

      final bool? started = await _channel
          .invokeMethod<bool>('playWhistle', audioBytes)
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      return started == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List> _loadAudioBytes() async {
    final ByteData data = await rootBundle.load(_assetPath);
    return Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}
