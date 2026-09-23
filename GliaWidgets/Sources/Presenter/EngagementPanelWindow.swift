import UIKit

/// A full-scene, SDK-owned window that is transparent to touches everywhere
/// except over Glia-owned content, so the integrator's app stays visible and
/// interactive beside the docked panel.
final class EngagementPanelWindow: UIWindow, GliaOwnedWindow {
    /// The host window that was key before the panel took key status, so it can
    /// be restored exactly even when the host app has several windows.
    private weak var previousKeyWindow: UIWindow?

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        // Points landing on the window's own root view are outside every Glia-owned
        // region, so they must reach the integrator's app underneath.
        guard hit !== rootViewController?.view else {
            resignKeyToHostWindow()
            return nil
        }
        // iOS delivers keyboard input to the key window only, so the panel has to
        // take key status when the visitor touches it and give it back when they
        // touch the host app. Two live windows in one scene share one keyboard.
        takeKeyFromHostWindow()
        return hit
    }

    /// Makes the panel key, remembering which host window held key status so
    /// `resignKeyToHostWindow()` can hand it back. No-op when already key.
    func takeKeyFromHostWindow() {
        guard !isKeyWindow else { return }
        if let currentKeyWindow = windowScene?.keyWindow, !(currentKeyWindow is GliaOwnedWindow) {
            previousKeyWindow = currentKeyWindow
        }
        makeKey()
    }

    /// Hands key-window status back to the integrator's window, if this window
    /// currently holds it. Safe to call when the panel is not key.
    func resignKeyToHostWindow() {
        guard isKeyWindow else { return }
        let fallbackHostWindow = windowScene?.windows.first {
            !($0 is GliaOwnedWindow) && !$0.isHidden
        }
        let hostWindow = previousKeyWindow.flatMap { $0.isHidden ? nil : $0 } ?? fallbackHostWindow
        previousKeyWindow = nil
        hostWindow?.makeKey()
    }

    private func setup() {
        windowLevel = .normal + 1
    }
}
