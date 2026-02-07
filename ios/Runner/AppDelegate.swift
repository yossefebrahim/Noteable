import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
    // Pass the URL to Flutter for routing
    var navigationController: UINavigationController?
    navigationController = window?.rootViewController as? UINavigationController

    // Let Flutter engine handle the deep link
    let controller = window?.rootViewController as? FlutterViewController
    controller?.engine?.launchUrl(url)

    return true
  }
}
