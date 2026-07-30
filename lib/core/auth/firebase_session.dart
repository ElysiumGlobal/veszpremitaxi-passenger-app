import 'package:e_taxi/utils/build_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseSession {
  FirebaseSession._();

  static bool get isEnabled => BuildConfig.firebaseEnabled;

  static User? get currentUser {
    if (!isEnabled) return null;
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  static bool get hasSignedInUser => currentUser != null;

  static Future<String> idToken({bool forceRefresh = true}) async {
    final user = currentUser;
    if (user == null) return '';
    return (await user.getIdToken(forceRefresh)) ?? '';
  }

  static Future<void> signOut() async {
    if (!isEnabled) return;

    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // The user may have signed in with email/password only.
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Logout must still clear the Laravel session if Firebase is unavailable.
    }
  }
}
