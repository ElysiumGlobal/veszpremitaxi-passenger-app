import 'dart:io';

class BuildConfig {
  /// The Veszprémi Taxi Firebase project is configured for the Android
  /// passenger application. iOS is intentionally kept disabled until the
  /// Apple bundle is registered in the same project.
  static const bool firebaseProjectConfigured = true;

  static bool get firebaseEnabled =>
      firebaseProjectConfigured && Platform.isAndroid;

  static bool get googleLoginEnabled => firebaseEnabled;

  static const bool appleLoginEnabled = false;

  /// Push is switched on in a separate release after the login flow is
  /// accepted. This avoids mixing authentication testing with notification
  /// permission prompts.
  static const bool pushNotificationsEnabled = false;
}
