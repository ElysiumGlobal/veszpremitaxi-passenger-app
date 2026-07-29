import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/api/api.dart';
import '../../utils/api_constants.dart';

/// Ideiglenes, nem blokkoló utasoldali folyamatnapló.
///
/// Nem küld hitelesítési tokent, telefonszámot, nevet, címet vagy teljes
/// koordinátát. A naplózási hiba soha nem akadályozhatja a rendelést.
class PassengerFlowDebug {
  PassengerFlowDebug._();

  static const String appVersion = '1.0.9+18';
  static final String sessionId =
      'psg-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';
  static int _sequence = 0;

  static void send(
    String event, {
    String bookingId = '',
    Map<String, dynamic>? data,
  }) {
    final int sequence = ++_sequence;
    final Map<String, dynamic> payload = <String, dynamic>{
      'event': event,
      'session_id': sessionId,
      'sequence': sequence,
      'booking_id': bookingId,
      'client_time': DateTime.now().toUtc().toIso8601String(),
      'app_version': appVersion,
      'route': Get.currentRoute,
      'data': _sanitizeMap(data ?? const <String, dynamic>{}),
    };

    log('VTAXI_PASSENGER_FLOW ${jsonEncode(payload)}');
    unawaited(_send(payload));
  }

  static Future<void> _send(Map<String, dynamic> payload) async {
    try {
      await http
          .post(
            Uri.parse(ApiConstants.flowDebugEvent),
            headers: await headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // A telemetria láthatatlan marad és nem hathat a valódi fuvarfolyamatra.
    }
  }

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> input) {
    final Map<String, dynamic> output = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in input.entries) {
      final String key = entry.key.toLowerCase();
      if (key.contains('token') ||
          key.contains('authorization') ||
          key.contains('password') ||
          key.contains('secret') ||
          key.contains('phone') ||
          key.contains('email') ||
          key.contains('name') ||
          key.contains('address') ||
          key.contains('photo')) {
        continue;
      }
      output[entry.key] = _sanitizeValue(entry.value);
    }
    return output;
  }

  static dynamic _sanitizeValue(dynamic value) {
    if (value == null || value is bool || value is int || value is double) {
      return value;
    }
    if (value is Map) {
      return _sanitizeMap(
        value.map<String, dynamic>(
          (dynamic key, dynamic item) =>
              MapEntry<String, dynamic>(key.toString(), item),
        ),
      );
    }
    if (value is Iterable) {
      return value.take(30).map<dynamic>(_sanitizeValue).toList();
    }
    final String text = value.toString();
    return text.length <= 400 ? text : text.substring(0, 400);
  }

  static double coordinate(double value) {
    return double.parse(value.toStringAsFixed(4));
  }
}
