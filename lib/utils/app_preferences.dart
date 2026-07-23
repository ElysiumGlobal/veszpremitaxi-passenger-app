import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../feature/auth/model/register_model.dart';

class AppPreference {
  static late SharedPreferences _prefs;

  static const String _languageKey = 'languageKey1';
  static const String onboardingDone = "OnBoardingDone1";
  static const String userToken = "userToken1";
  static const String userLogin = "userLogin1";

  static const String userModel = "userModel1";
  static const String languageIndex = "languageIndex";
  static const String userLoginDetailsModel = "userLoginDetailsModel1";
  static const String userId = "USERID";
  static const String rideType = "rideType";
  static const String RideTime = "RideTime";
  static const String bookingFare = "bookingFare";

  static const location = "Location0";
  static const walletData = "walletData";

  static Future initMySharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> clearSharedPreferences() async {
    await _prefs.clear();
  }

  static void removeKey(String key) {
    _prefs.remove(key);
  }

  static Future setString(String key, String value) async {
    await _prefs.setString(key, value);
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

  static String getLanguage() {
    final String? value = _prefs.getString(_languageKey);
    return value ?? 'en';
  }

  static Future setLanguage(String value) async {
    await _prefs.setString(_languageKey, value);
  }

  static setUserModel(User? user) {
    _prefs.setString(userModel, jsonEncode(user?.toJson()));
  }

  static User? getUserModel() {
    var data = _prefs.getString(userModel) ?? "";

    if (data.isEmpty) {
      return null;
    }
    Map<String, dynamic> model = jsonEncode(data) as Map<String, dynamic>;
    return User.fromJson(model);
  }
}
