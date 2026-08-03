import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;
  static const String _languageKey = 'languageKey';
  static const String onboardingDone = 'onboardingDoneV2';
  static const String userToken = "userToken";
  static const String userStep = "userStepComplete";
  static const String userInitData = "userIniData";
  static const String userRegisterStepComplete = "userRegiStepComp";
  static const String profileApprove = "ProfileApprove";
  static const String userId = "UserID";
  static const String languageIndex = "LanguageIndexave";
  static const String location = "USER LOCATION";
  static const String driverRideType = "driverRideType";
  static const String driverRideTime = "driverRideTime";
  static const String driverOnline = "driverOnline";

  static Future initMySharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static Future<void> clearSharedPreferences() async {
    await _prefs.clear();
    return;
  }

  static String getLanguage() {
    final String? value = _prefs.getString(_languageKey);
    return value ?? 'en';
  }

  static Future setLanguage(String value) async {
    await _prefs.setString(_languageKey, value);
  }

  static Future setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static void removeKey(String key) {
    _prefs.remove(key);
  }

  static String getString(String key) {
    final String? value = _prefs.getString(key);
    return value ?? "";
  }

  static Future setBoolean(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }

  static bool getBoolean(String key) {
    final bool? value = _prefs.getBool(key);
    return value ?? false;
  }

  static Future setLong(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double getLong(String key) {
    final double? value = _prefs.getDouble(key);
    return value ?? 0.0;
  }

  static Future setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int getInt(String key) {
    final int? value = _prefs.getInt(key);
    return value ?? 0;
  }

  static setProfileModel(String data) {
    _prefs.setString("USERPROFILEDATA", data);
  }

  static String getProfileData() {
    return _prefs.getString("USERPROFILEDATA") ?? "";
  }
}
