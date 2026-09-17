import Flutter
import UIKit

public class IprScreenBlurPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let blocker = ScreenshotBlocker()
  private let overlay = PrivacyOverlay()
  private lazy var captureMonitor = CaptureMonitor { [weak self] event in
    self?.eventSink?(event)
  }
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = IprScreenBlurPlugin()
    let methods = FlutterMethodChannel(
      name: "ipr_screen_blur/methods", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methods)
    let events = FlutterEventChannel(
      name: "ipr_screen_blur/events", binaryMessenger: registrar.messenger())
    events.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setSecureMode":
      guard let args = call.arguments as? [String: Any], let enabled = args["enabled"] as? Bool
      else {
        result(
          FlutterError(code: "invalid_arguments", message: "'enabled' must be a bool", details: nil))
        return
      }
      setSecureMode(enabled)
      result(nil)
    case "isScreenCaptured":
      result(captureMonitor.isCaptured)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setSecureMode(_ enabled: Bool) {
    if enabled {
      blocker.enable()
      overlay.enable()
    } else {
      blocker.disable()
      overlay.disable()
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    eventSink = events
    captureMonitor.start()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    captureMonitor.stop()
    eventSink = nil
    return nil
  }
}

extension UIApplication {
  var windowScenes: [UIWindowScene] {
    connectedScenes.compactMap { $0 as? UIWindowScene }
  }
}

extension UIWindowScene {
  /// The app's own windows, excluding system ones such as the keyboard window.
  var appWindows: [UIWindow] {
    windows.filter { $0.windowLevel == .normal }
  }
}
