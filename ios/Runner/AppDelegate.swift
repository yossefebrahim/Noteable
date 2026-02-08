import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set up widget refresh method channel
    setupWidgetRefreshChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Set up method channel for widget refresh
  private func setupWidgetRefreshChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let widgetChannel = FlutterMethodChannel(
      name: "com.example.noteable/widgets",
      binaryMessenger: controller.binaryMessenger
    )

    widgetChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "refreshWidgets":
        if #available(iOS 14.0, *) {
          self?.refreshAllWidgets()
        }
        result(nil)
        
      case "getAppGroupDirectory":
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "App group identifier is required",
                            details: nil))
          return
        }
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) {
          result(containerURL.path)
        } else {
          result(FlutterError(code: "UNAVAILABLE",
                            message: "App group directory not available",
                            details: nil))
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // Refresh all widget timelines
  @available(iOS 14.0, *)
  private func refreshAllWidgets() {
    // Reload all widget types
    let widgetKinds = [
      "QuickCaptureWidget",
      "RecentNotesWidget",
      "PinnedNotesWidget"
    ]

    // Reload each widget kind individually
    for kind in widgetKinds {
      WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }
  }

  // Handle incoming deep link when app is opened from a widget tap
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return handleDeepLink(url)
  }

  // Handle universal links and continuation streams
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let url = userActivity.webpageURL {
      return handleDeepLink(url)
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  private func handleDeepLink(_ url: URL) -> Bool {
    // Pass the URL to Flutter for routing via method channel
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return false
    }

    let deepLinkChannel = FlutterMethodChannel(
      name: "com.example.noteable/deeplink",
      binaryMessenger: controller.binaryMessenger
    )

    // Send the URL to Flutter
    deepLinkChannel.invokeMethod("handleDeepLink", arguments: url.absoluteString)

    return true
  }
}
