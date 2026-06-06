import FirebaseAppCheck
import FirebaseCore
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Must run before Firebase initializes — DeviceCheck is unavailable on Simulator.
    #if DEBUG
    AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
    #endif
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerAppCheckDebugChannel(engineBridge.applicationRegistrar)
  }

  private func registerAppCheckDebugChannel(_ registrar: FlutterApplicationRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.vettedclub/app_check_debug",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "getDebugToken" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let app = FirebaseApp.app() else {
        result(
          FlutterError(
            code: "NO_FIREBASE_APP",
            message: "Firebase not initialized",
            details: nil
          )
        )
        return
      }
      guard let provider = AppCheckDebugProvider(app: app) else {
        result(
          FlutterError(
            code: "NO_DEBUG_PROVIDER",
            message: "App Check debug provider unavailable",
            details: nil
          )
        )
        return
      }
      result(provider.localDebugToken())
    }
  }
}
