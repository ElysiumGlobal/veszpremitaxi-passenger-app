import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class VTaxiAudioService {
  VTaxiAudioService._();

  static const MethodChannel _channel = MethodChannel(
    'hu.veszpremitaxi.passenger/audio',
  );

  static const String _arrivalAsset =
      'assets/sounds/taxi_arrived_whistle.wav';
  static const String _chatAsset = 'assets/sounds/vtaxi_chat_beep.wav';

  static final Map<String, Uint8List> _iosAudioCache = <String, Uint8List>{};

  static Future<bool> playArrivalWhistle() {
    return _play('playArrivalWhistle', _arrivalAsset);
  }

  static Future<bool> playChatBeep() {
    return _play('playChatBeep', _chatAsset);
  }

  static Future<bool> _play(String method, String assetPath) async {
    try {
      if (Platform.isAndroid) {
        final bool? started = await _channel
            .invokeMethod<bool>(method)
            .timeout(const Duration(seconds: 2), onTimeout: () => false);
        return started == true;
      }

      final Uint8List bytes = _iosAudioCache[assetPath] ??=
          await _loadAudioBytes(assetPath);
      if (bytes.isEmpty) return false;

      final bool? started = await _channel
          .invokeMethod<bool>(method, bytes)
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      return started == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List> _loadAudioBytes(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}
