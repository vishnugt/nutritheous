import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("🍎 iOS: AppDelegate didFinishLaunchingWithOptions called")

    // Call super FIRST to initialize Flutter engine
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    print("✅ iOS: Super didFinishLaunchingWithOptions completed with result: \(result)")

    // Register plugins immediately (no delay)
    print("🔌 iOS: Starting plugin registration...")
    GeneratedPluginRegistrant.register(with: self)
    print("✅ iOS: Plugins registered successfully")

    return result
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    print("⚠️ iOS: App will terminate")
    super.applicationWillTerminate(application)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    print("🔚 iOS: App entered background")
    super.applicationDidEnterBackground(application)
  }

  override func applicationWillEnterForeground(_ application: UIApplication) {
    print("🔙 iOS: App will enter foreground")
    super.applicationWillEnterForeground(application)
  }
}
