import Flutter
import UIKit

public class IprScreenBlurPlugin: NSObject, FlutterPlugin, SecureScreenHostApi {
  private let blocker = ScreenshotBlocker()
  private let overlay = PrivacyOverlay()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = IprScreenBlurPlugin()
    SecureScreenHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    let eventHandler = ScreenEventStreamHandler()
    StreamScreenEventsStreamHandler.register(
      with: registrar.messenger(), streamHandler: eventHandler)
    registrar.publish(instance)
    instance.eventHandler = eventHandler
  }

  private var eventHandler: ScreenEventStreamHandler?

  func setSecureMode(enabled: Bool) throws {
    if enabled {
      blocker.enable()
      overlay.enable()
    } else {
      blocker.disable()
      overlay.disable()
    }
  }

  func isScreenCaptured() throws -> Bool {
    CaptureMonitor.isCaptured
  }
}

final class ScreenEventStreamHandler: StreamScreenEventsStreamHandler {
  private var sink: PigeonEventSink<ScreenEvent>?
  private lazy var monitor = CaptureMonitor { [weak self] event in
    self?.sink?.success(event)
  }

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<ScreenEvent>) {
    self.sink = sink
    monitor.start()
  }

  override func onCancel(withArguments arguments: Any?) {
    monitor.stop()
    sink = nil
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
