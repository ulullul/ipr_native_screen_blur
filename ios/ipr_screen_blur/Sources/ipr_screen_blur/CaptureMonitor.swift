import UIKit

/// Reports screenshots and changes of the screen capture state (recording,
/// AirPlay, mirroring) as event channel payloads.
final class CaptureMonitor {
  typealias EventHandler = ([String: Any]) -> Void

  private let onEvent: EventHandler
  private var observers: [NSObjectProtocol] = []
  private var traitUnregistrations: [ObjectIdentifier: () -> Void] = [:]
  private var lastCaptured = false

  init(onEvent: @escaping EventHandler) {
    self.onEvent = onEvent
  }

  var isCaptured: Bool {
    let scenes = UIApplication.shared.windowScenes
    if #available(iOS 17.0, *) {
      return scenes.contains { $0.traitCollection.sceneCaptureState == .active }
    }
    return scenes.contains { $0.screen.isCaptured }
  }

  func start() {
    guard observers.isEmpty else { return }
    lastCaptured = isCaptured
    let center = NotificationCenter.default

    observers.append(
      center.addObserver(
        forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main
      ) { [weak self] _ in
        self?.onEvent(["type": "screenshotTaken"])
      })

    if #available(iOS 17.0, *) {
      MainActor.assumeIsolated { observeTraitsOfAllWindows() }

      observers.append(
        center.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: .main) {
          [weak self] _ in
          MainActor.assumeIsolated { self?.observeTraitsOfAllWindows() }
          self?.reportCaptureStateIfChanged()
        })
    } else {
      observers.append(
        center.addObserver(
          forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
          self?.reportCaptureStateIfChanged()
        })
    }
  }

  func stop() {
    observers.forEach(NotificationCenter.default.removeObserver)
    observers.removeAll()
    traitUnregistrations.values.forEach { $0() }
    traitUnregistrations.removeAll()
  }

  @available(iOS 17.0, *)
  @MainActor
  private func observeTraitsOfAllWindows() {
    for window in UIApplication.shared.windowScenes.flatMap(\.appWindows) {
      let id = ObjectIdentifier(window)
      guard traitUnregistrations[id] == nil else { continue }
      let registration = window.registerForTraitChanges([UITraitSceneCaptureState.self]) {
        [weak self] (_: UIWindow, _: UITraitCollection) in
        self?.reportCaptureStateIfChanged()
      }
      traitUnregistrations[id] = { [weak window] in
        MainActor.assumeIsolated { window?.unregisterForTraitChanges(registration) }
      }
    }
  }

  private func reportCaptureStateIfChanged() {
    let captured = isCaptured
    guard captured != lastCaptured else { return }
    lastCaptured = captured
    onEvent(["type": "captureStateChanged", "captured": captured])
  }
}
