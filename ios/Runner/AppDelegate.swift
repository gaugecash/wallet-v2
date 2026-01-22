import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Setup method channel for iCloud backup integration
    let controller = window?.rootViewController as! FlutterViewController
    let backupChannel = FlutterMethodChannel(
      name: "com.gaugecash.wallet/backup",
      binaryMessenger: controller.binaryMessenger
    )

    backupChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getICloudPath" {
        self.getICloudContainerPath(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Returns the iCloud ubiquity container path for automatic backup
  /// Returns nil if iCloud is not available (user has iCloud disabled)
  private func getICloudContainerPath(result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .background).async {
      // Request iCloud container URL (nil = default container from entitlements)
      if let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
        // Ensure Documents directory exists
        let documentsURL = containerURL.appendingPathComponent("Documents")

        do {
          try FileManager.default.createDirectory(
            at: documentsURL,
            withIntermediateDirectories: true,
            attributes: nil
          )

          DispatchQueue.main.async {
            result(documentsURL.path)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "ICLOUD_ERROR",
              message: "Failed to create iCloud Documents directory: \(error.localizedDescription)",
              details: nil
            ))
          }
        }
      } else {
        DispatchQueue.main.async {
          // iCloud not available - user has iCloud disabled or not signed in
          // This is expected for ~20-30% of iOS users
          result(nil)
        }
      }
    }
  }
}
