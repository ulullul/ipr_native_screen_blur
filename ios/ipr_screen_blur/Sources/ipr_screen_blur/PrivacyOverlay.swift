import UIKit

final class PrivacyOverlay {
    private var observers: [NSObjectProtocol] = []
    private var overlays: [ObjectIdentifier: [UIView]] = [:]

    func enable() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        observers = [
            center.addObserver(
                forName: UIScene.willDeactivateNotification,
                object: nil,
                queue: .main
            ) {
                [weak self] note in
                guard let scene = note.object as? UIWindowScene else { return }
                self?.show(on: scene)
            },
            center.addObserver(
                forName: UIScene.didActivateNotification,
                object: nil,
                queue: .main
            ) {
                [weak self] note in
                guard let scene = note.object as? UIWindowScene else { return }
                self?.hide(on: scene)
            },
        ]
    }

    func disable() {
        observers.forEach(NotificationCenter.default.removeObserver)
        observers.removeAll()
        overlays.values.joined().forEach { $0.removeFromSuperview() }
        overlays.removeAll()
    }

    private func show(on scene: UIWindowScene) {
        let id = ObjectIdentifier(scene)
        guard overlays[id] == nil else { return }
        overlays[id] = scene.appWindows.map { window in
            let view = UIView(frame: window.bounds)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let blurEffectView = UIVisualEffectView(
                effect: UIBlurEffect(style: .systemUltraThinMaterial)
            )
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
            window.addSubview(view)
            return view
        }
    }

    private func hide(on scene: UIWindowScene) {
        overlays.removeValue(forKey: ObjectIdentifier(scene))?.forEach {
            $0.removeFromSuperview()
        }
    }
}
