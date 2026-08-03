
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXlQszBfDnu5LgNPvYQAJtF2-NXlXf8tk',
    appId: '1:59887336692:android:154356566626dfc8ccf2a1',
    messagingSenderId: '59887336692',
    projectId: 'e-taxi-649bb',
    storageBucket: 'e-taxi-649bb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYWm4r3kh3fnOJGT0guI8BfPBdmaY0OAo',
    appId: '1:59887336692:ios:5552cb6fea7ec848ccf2a1',
    messagingSenderId: '59887336692',
    projectId: 'e-taxi-649bb',
    storageBucket: 'e-taxi-649bb.firebasestorage.app',
    androidClientId:
        '59887336692-27s531pulcu69g3vnjphpdqhgvu379ns.apps.googleusercontent.com',
    iosClientId:
        '59887336692-aeq9adjidn8c3emrr9uqu7f5mc8mnnkt.apps.googleusercontent.com',
    iosBundleId: 'com.netsofters.etaxidriver',
  );
}
