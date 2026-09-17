import UIKit

final class ScreenshotBlocker {
  private struct Protection {
    weak var window: UIWindow?
    let field: UITextField
    let originalSuperlayer: CALayer
  }

  private var protections: [ObjectIdentifier: Protection] = [:]
  private var sceneObserver: NSObjectProtocol?

  func enable() {
    guard sceneObserver == nil else { return }
    protectAllWindows()
    // Windows of scenes that connect later.
    sceneObserver = NotificationCenter.default.addObserver(
      forName: UIScene.didActivateNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.protectAllWindows()
    }
  }

  func disable() {
    if let sceneObserver {
      NotificationCenter.default.removeObserver(sceneObserver)
    }
    sceneObserver = nil
    for protection in protections.values {
      guard let window = protection.window else { continue }
      protection.originalSuperlayer.addSublayer(window.layer)
      protection.field.layer.removeFromSuperlayer()
      protection.field.removeFromSuperview()
    }
    protections.removeAll()
  }

  private func protectAllWindows() {
    for window in UIApplication.shared.windowScenes.flatMap(\.appWindows) {
      protect(window)
    }
  }

  private func protect(_ window: UIWindow) {
    let id = ObjectIdentifier(window)
    guard protections[id]?.window == nil else { return }
    guard let superlayer = window.layer.superlayer else {
      NSLog("[ipr_screen_blur] window has no superlayer yet, not protected")
      return
    }

    let field = UITextField()
    field.isSecureTextEntry = true
    field.isUserInteractionEnabled = false
    window.addSubview(field)
    superlayer.addSublayer(field.layer)

    guard let canvas = secureCanvas(of: field) else {
      NSLog("[ipr_screen_blur] secure text field layout changed, screenshots are not blocked")
      field.layer.removeFromSuperlayer()
      field.removeFromSuperview()
      return
    }
    canvas.addSublayer(window.layer)
    protections[id] = Protection(window: window, field: field, originalSuperlayer: superlayer)
  }

  private func secureCanvas(of field: UITextField) -> CALayer? {
    let sublayers = field.layer.sublayers ?? []
    let byName = sublayers.first { layer in
      guard let delegate = layer.delegate else { return false }
      return String(describing: type(of: delegate)).contains("CanvasView")
    }
    return byName ?? sublayers.last
  }
}
