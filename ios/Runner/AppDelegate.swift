
import UIKit
import FirebaseCore
import GoogleMaps
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }

      GMSServices.provideAPIKey("GOOGLE_MAPS_API_KEY_IOS")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
