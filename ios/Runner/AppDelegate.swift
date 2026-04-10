import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let mapsConfigChannelName = "com.example.car_wash/maps_config"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let apiKey =
      (Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String)
      ?? "YOUR_GOOGLE_MAPS_API_KEY"
    GMSServices.provideAPIKey(apiKey)
    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: mapsConfigChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "hasUsableGoogleMapsApiKey":
          result(self?.hasUsableGoogleMapsApiKey() ?? false)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return didFinish
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func hasUsableGoogleMapsApiKey() -> Bool {
    let apiKey =
      (Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return !(apiKey?.isEmpty ?? true) && apiKey != "YOUR_GOOGLE_MAPS_API_KEY"
  }
}
