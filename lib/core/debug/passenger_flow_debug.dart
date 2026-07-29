import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../utils/api_constants.dart';
import '../../utils/app_preferences.dart';

/// Nem blokkoló, szűrt utasoldali folyamatnapló.
///
/// A napló célja a teljes rendelési lánc követése: képernyő, API, socket,
/// aktuális booking, státuszváltás, térkép és chat. Titkot, tokent, személyes
/// adatot és utazási kódot nem küld a szerverre.
class PassengerFlowDebug {
  PassengerFlowDebug._();

  static const String appVersion = '1.0.13+22';
  static const String expectedCollectorVersion =
      '2026-07-29-role2-role3-v2';
  static final String sessionId =
      'psg-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';

  static int _sequence = 0;
  static bool _draining = false;
  static Timer? _retryTimer;
  static final List<Map<String, dynamic>> _queue = <Map<String, dynamic>>[];

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
      'data': sanitizeMap(data ?? const <String, dynamic>{}),
    };

    log('VTAXI_PASSENGER_FLOW ${jsonEncode(payload)}');

    if (_queue.length >= 300) {
      _queue.removeAt(0);
    }
    _queue.add(payload);
    unawaited(_drainQueue());
  }

  static void apiRequest({
    required String method,
    required String endpoint,
    String bookingId = '',
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) {
    send(
      'api_request',
      bookingId: bookingId,
      data: <String, dynamic>{
        'method': method,
        'endpoint': endpoint,
        'query': query ?? const <String, dynamic>{},
        'body': body ?? const <String, dynamic>{},
      },
    );
  }

  static void apiResponse({
    required String method,
    required String endpoint,
    required int statusCode,
    required int durationMs,
    required String responseBody,
    String bookingId = '',
  }) {
    send(
      'api_response',
      bookingId: bookingId,
      data: <String, dynamic>{
        'method': method,
        'endpoint': endpoint,
        'status_code': statusCode,
        'duration_ms': durationMs,
        'response': summarizeResponse(responseBody),
      },
    );
  }

  static void apiError({
    required String method,
    required String endpoint,
    required Object error,
    required int durationMs,
    String bookingId = '',
  }) {
    send(
      'api_error',
      bookingId: bookingId,
      data: <String, dynamic>{
        'method': method,
        'endpoint': endpoint,
        'duration_ms': durationMs,
        'error_type': error.runtimeType.toString(),
        'error': error.toString(),
      },
    );
  }

  static void runtimeError(
    String source,
    Object error,
    StackTrace? stackTrace,
  ) {
    send(
      'runtime_error',
      data: <String, dynamic>{
        'source': source,
        'error_type': error.runtimeType.toString(),
        'error': error.toString(),
        'stack': stackTrace?.toString() ?? '',
      },
    );
  }

  static void kick() {
    _retryTimer?.cancel();
    _retryTimer = null;
    unawaited(_drainQueue());
  }

  static void _scheduleRetry([Duration delay = const Duration(seconds: 2)]) {
    if (_retryTimer?.isActive ?? false) return;
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      unawaited(_drainQueue());
    });
  }

  static Future<void> _drainQueue() async {
    if (_draining || _queue.isEmpty) return;

    final String token =
        AppPreference.getString(AppPreference.userToken).trim();
    if (token.isEmpty) {
      // A belépés előtti eseményeket nem dobjuk el. A token mentése után
      // a redirectUser() meghívja a kick() metódust, és a teljes előzmény
      // hitelesítve bekerül a szerveroldali debugnaplóba.
      _scheduleRetry(const Duration(seconds: 3));
      return;
    }

    _draining = true;

    try {
      while (_queue.isNotEmpty) {
        final Map<String, dynamic> payload = _queue.first;
        bool delivered = false;
        int? lastStatusCode;
        Object? lastError;

        for (int attempt = 1; attempt <= 3 && !delivered; attempt++) {
          try {
            final Map<String, String> requestHeaders = <String, String>{
              'accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'X-VTaxi-Debug-Client': appVersion,
            };

            final http.Response response = await http
                .post(
                  Uri.parse(ApiConstants.flowDebugEvent),
                  headers: requestHeaders,
                  body: jsonEncode(payload),
                )
                .timeout(const Duration(seconds: 10));

            lastStatusCode = response.statusCode;
            delivered = response.statusCode >= 200 && response.statusCode < 300;
            log(
              'VTAXI_PASSENGER_FLOW_DELIVERY event=${payload['event']} '
              'sequence=${payload['sequence']} status=${response.statusCode}',
            );

            if (delivered) break;

            // Rossz payloadot vagy nem létező végpontot nem tartunk a sor
            // elején örökké. Hitelesítési, rate-limit és szerverhibánál viszont
            // megőrizzük, mert ezek tipikusan átmeneti állapotok.
            if (<int>{400, 404, 405, 413, 422}.contains(response.statusCode)) {
              break;
            }
          } catch (error) {
            lastError = error;
            log(
              'VTAXI_PASSENGER_FLOW_DELIVERY_FAILED '
              'event=${payload['event']} sequence=${payload['sequence']} '
              'attempt=$attempt error=${error.runtimeType}',
            );
          }

          if (!delivered && attempt < 3) {
            await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
          }
        }

        if (delivered ||
            (lastStatusCode != null &&
                <int>{400, 404, 405, 413, 422}.contains(lastStatusCode))) {
          _queue.removeAt(0);
          continue;
        }

        log(
          'VTAXI_PASSENGER_FLOW_QUEUE_PAUSED '
          'event=${payload['event']} sequence=${payload['sequence']} '
          'status=${lastStatusCode ?? 'network'} '
          'error=${lastError?.runtimeType ?? ''}',
        );
        _scheduleRetry(const Duration(seconds: 3));
        return;
      }
    } finally {
      _draining = false;
      if (_queue.isNotEmpty && !(_retryTimer?.isActive ?? false)) {
        _scheduleRetry();
      }
    }
  }

  static Map<String, dynamic> summarizeResponse(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{'empty': true};
    }

    try {
      final dynamic decoded = jsonDecode(body);
      final dynamic sanitized = sanitizeValue(decoded);
      if (sanitized is Map<String, dynamic>) {
        return sanitized;
      }
      return <String, dynamic>{'value': sanitized};
    } catch (_) {
      final String text = body.length <= 800 ? body : body.substring(0, 800);
      return <String, dynamic>{'non_json': text};
    }
  }

  static Map<String, dynamic> sanitizeMap(
    Map<String, dynamic> input, {
    int depth = 0,
  }) {
    if (depth > 6) {
      return <String, dynamic>{'_depth_limit': true};
    }

    final Map<String, dynamic> output = <String, dynamic>{};
    int count = 0;

    for (final MapEntry<String, dynamic> entry in input.entries) {
      count++;
      if (count > 80) {
        output['_truncated'] = true;
        break;
      }

      if (_blockedKey(entry.key)) continue;
      output[entry.key] = sanitizeValue(entry.value, depth: depth + 1);
    }
    return output;
  }

  static dynamic sanitizeValue(dynamic value, {int depth = 0}) {
    if (depth > 6) return '[depth-limit]';
    if (value == null || value is bool || value is int || value is double) {
      return value;
    }
    if (value is Map) {
      return sanitizeMap(
        value.map<String, dynamic>(
          (dynamic key, dynamic item) =>
              MapEntry<String, dynamic>(key.toString(), item),
        ),
        depth: depth + 1,
      );
    }
    if (value is Iterable) {
      return value
          .take(40)
          .map<dynamic>((dynamic item) => sanitizeValue(item, depth: depth + 1))
          .toList();
    }
    final String text = value.toString();
    return text.length <= 800 ? text : text.substring(0, 800);
  }

  static bool _blockedKey(String originalKey) {
    final String key = originalKey.toLowerCase().trim();
    const Set<String> exact = <String>{
      'otp',
      'trip_code',
      'booking_code',
      'verification_code',
      'pin',
      'password',
      'access_token',
      'refresh_token',
      'name',
      'full_name',
      'first_name',
      'last_name',
      'driver_name',
      'user_name',
      'passenger_name',
      'customer_name',
    };
    if (exact.contains(key)) return true;

    const List<String> fragments = <String>[
      'authorization',
      'token',
      'password',
      'secret',
      'phone',
      'email',
      'address',
      'photo',
      'avatar',
    ];
    if (fragments.any(key.contains)) return true;
    return key.endsWith('_name') && key != 'event_name';
  }

  static String bookingIdFrom({
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) {
    for (final Map<String, dynamic>? source in <Map<String, dynamic>?>[body, query]) {
      if (source == null) continue;
      for (final String key in <String>['booking_id', 'bookingId']) {
        final dynamic value = source[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }
    return '';
  }

  static double coordinate(double value) {
    return double.parse(value.toStringAsFixed(4));
  }
}

class PassengerDebugNavigatorObserver extends NavigatorObserver {
  void _logRoute(
    String action,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    PassengerFlowDebug.send(
      'route_changed',
      data: <String, dynamic>{
        'action': action,
        'route_to': route?.settings.name ?? route?.runtimeType.toString() ?? '',
        'route_from':
            previousRoute?.settings.name ?? previousRoute?.runtimeType.toString() ?? '',
      },
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRoute('pop', previousRoute, route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRoute('replace', newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logRoute('remove', previousRoute, route);
  }
}

class PassengerDebugLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    PassengerFlowDebug.send(
      'app_lifecycle_changed',
      data: <String, dynamic>{'state': state.name},
    );
  }
}

