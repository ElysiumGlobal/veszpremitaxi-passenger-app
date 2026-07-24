class BuildConfig {
  /// Keep this false until the Veszprémi Taxi Firebase project is connected.
  /// The bundled vendor Firebase files must not be used in production.
  static const bool firebaseEnabled = false;

  static const bool googleLoginEnabled = firebaseEnabled;
  static const bool appleLoginEnabled = firebaseEnabled;
  static const bool pushNotificationsEnabled = firebaseEnabled;
}
