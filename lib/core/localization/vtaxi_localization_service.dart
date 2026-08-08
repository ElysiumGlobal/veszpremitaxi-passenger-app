import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../utils/api_constants.dart';
import '../../utils/app_preferences.dart';

class VTaxiLocalizationService {
  static const String _cacheKey = 'vtaxi.hu.app.strings.v1';
  static const String _versionKey = 'vtaxi.hu.app.version.v1';
  static final Map<String, String> _remote = <String, String>{};

  static Map<String, String> get remoteStrings => Map<String, String>.unmodifiable(_remote);

  static Future<void> loadCached() async {
    final raw = AppPreference.getString(_cacheKey);
    if (raw.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _replace(decoded);
      }
    } catch (_) {
      AppPreference.removeKey(_cacheKey);
      AppPreference.removeKey(_versionKey);
    }
  }

  static Future<void> refreshFromBackend() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getAppLanguage}'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return;
      final payload = jsonDecode(response.body);
      if (payload is! Map || payload['success'] != true) return;
      final data = payload['data'];
      if (data is! Map || data['strings'] is! Map) return;
      final version = (data['version'] ?? '').toString();
      final oldVersion = AppPreference.getString(_versionKey);
      final changed = version.isEmpty || version != oldVersion || _remote.isEmpty;
      _replace(data['strings'] as Map);
      await AppPreference.setString(_cacheKey, jsonEncode(_remote));
      if (version.isNotEmpty) await AppPreference.setString(_versionKey, version);
      if (changed) {
        Get.addTranslations(<String, Map<String, String>>{'hu_HU': Map<String, String>.from(_remote)});
        Get.updateLocale(const Locale('hu', 'HU'));
      }
    } catch (_) {
      // Offline or backend language failure must never block the taxi app.
    }
  }

  static Map<String, String> merge(Map<String, String> fallback) {
    return <String, String>{...fallback, ..._remote};
  }

  static String text(String key, String fallback) {
    final value = _remote[key]?.trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  static String textWith(String key, String fallback, Map<String, String> params) {
    var value = text(key, fallback);
    params.forEach((name, replacement) {
      value = value.replaceAll('{$name}', replacement);
    });
    return value;
  }

  static void _replace(Map source) {
    _remote
      ..clear()
      ..addEntries(source.entries.where((entry) => entry.key != null && entry.value != null).map(
        (entry) => MapEntry(entry.key.toString(), entry.value.toString()),
      ));
  }
}
