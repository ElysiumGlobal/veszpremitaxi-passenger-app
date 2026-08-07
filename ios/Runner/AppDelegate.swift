import UIKit
import FirebaseCore
import GoogleMaps
import Flutter
import flutter_local_notifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, AVAudioPlayerDelegate {
  private let audioChannelName = "hu.veszpremitaxi.passenger/audio"
  private let screenAwakeChannelName = "hu.veszpremitaxi.passenger/screen_awake"
  private var soundPlayer: AVAudioPlayer?

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
      let audioChannel = FlutterMethodChannel(
        name: audioChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      audioChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "playArrivalWhistle" || call.method == "playChatBeep" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard let typedData = call.arguments as? FlutterStandardTypedData,
              !typedData.data.isEmpty else {
          result(false)
          return
        }

        result(self?.playSound(data: typedData.data) ?? false)
      }

      let screenAwakeChannel = FlutterMethodChannel(
        name: screenAwakeChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      screenAwakeChannel.setMethodCallHandler { call, result in
        guard call.method == "setKeepAwake" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let keepAwake = (call.arguments as? Bool) ?? false
        DispatchQueue.main.async {
          UIApplication.shared.isIdleTimerDisabled = keepAwake
        }
        result(nil)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func playSound(data: Data) -> Bool {
    stopSound()

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [.duckOthers])
      try session.setActive(true)

      let player = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
      player.delegate = self
      player.volume = 1.0
      player.prepareToPlay()
      guard player.play() else {
        stopSound()
        return false
      }

      soundPlayer = player
      return true
    } catch {
      stopSound()
      return false
    }
  }

  private func stopSound() {
    soundPlayer?.stop()
    soundPlayer = nil
    try? AVAudioSession.sharedInstance().setActive(
      false,
      options: [.notifyOthersOnDeactivation]
    )
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    stopSound()
  }

  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    stopSound()
  }
}
