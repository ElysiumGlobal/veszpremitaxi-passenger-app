import UIKit
import FirebaseCore
import GoogleMaps
import Flutter
import flutter_local_notifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, AVAudioPlayerDelegate {
  private let arrivalSoundChannelName =
    "hu.veszpremitaxi.passenger/arrival_sound"
  private var arrivalSoundPlayer: AVAudioPlayer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate =
        self as? UNUserNotificationCenterDelegate
    }

    GMSServices.provideAPIKey("GOOGLE_MAPS_API_KEY_IOS")
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let arrivalSoundChannel = FlutterMethodChannel(
        name: arrivalSoundChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      arrivalSoundChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "playWhistle" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard let typedData = call.arguments as? FlutterStandardTypedData,
              !typedData.data.isEmpty else {
          result(false)
          return
        }

        result(self?.playArrivalWhistle(data: typedData.data) ?? false)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func playArrivalWhistle(data: Data) -> Bool {
    stopArrivalWhistle()

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(
        .playback,
        mode: .default,
        options: [.duckOthers]
      )
      try session.setActive(true)

      let player = try AVAudioPlayer(
        data: data,
        fileTypeHint: AVFileType.wav.rawValue
      )
      player.delegate = self
      player.volume = 1.0
      player.prepareToPlay()
      guard player.play() else {
        stopArrivalWhistle()
        return false
      }

      arrivalSoundPlayer = player
      return true
    } catch {
      stopArrivalWhistle()
      return false
    }
  }

  private func stopArrivalWhistle() {
    arrivalSoundPlayer?.stop()
    arrivalSoundPlayer = nil
    try? AVAudioSession.sharedInstance().setActive(
      false,
      options: [.notifyOthersOnDeactivation]
    )
  }

  func audioPlayerDidFinishPlaying(
    _ player: AVAudioPlayer,
    successfully flag: Bool
  ) {
    stopArrivalWhistle()
  }

  func audioPlayerDecodeErrorDidOccur(
    _ player: AVAudioPlayer,
    error: Error?
  ) {
    stopArrivalWhistle()
  }
}
