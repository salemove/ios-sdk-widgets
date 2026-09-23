import UIKit

/// Owns the minimized-bubble window lifecycle, shared by `GliaViewController`
/// (full-screen mode) and `EngagementCoordinator` (iPad side-panel mode).
final class BubblePresenter {
    var bubbleKind: BubbleKind = .userImage(url: nil) {
        willSet {
            environment.openTelemetry.logger.i(.bubbleStateChanged) {
                guard case .userImage = newValue else { return }
                $0[.bubbleState] = .string(OtelBubbleStates.operatorConnected.rawValue)
            }
        }
        didSet {
            bubbleWindow?.bubbleKind = bubbleKind
        }
    }

    private(set) var bubbleWindow: BubbleWindow?

    private var delegate: ((GliaViewControllerEvent) -> Void)?
    private let bubbleView: BubbleView?
    private var sceneProvider: SceneProvider?
    // Stealing key-window status is disruptive in side-panel mode, where the host
    // app remains live beside the panel; full-screen mode keeps the prior behavior.
    private let becomesKeyWindow: Bool
    private let features: Features
    private let environment: Environment

    init(
        bubbleView: BubbleView?,
        delegate: ((GliaViewControllerEvent) -> Void)?,
        sceneProvider: SceneProvider? = .none,
        becomesKeyWindow: Bool,
        features: Features,
        environment: Environment
    ) {
        self.bubbleView = bubbleView
        self.delegate = delegate
        self.sceneProvider = sceneProvider
        self.becomesKeyWindow = becomesKeyWindow
        self.features = features
        self.environment = environment
    }

    func setVisitorHoldState(isOnHold: Bool) {
        bubbleView?.isVisitorOnHold = isOnHold
    }

    func maximize(animated: Bool) {
        environment.log.prefixed(Self.self).info("Bubble: hide application-only bubble")
        environment.openTelemetry.logger.i(.bubbleHidden)
        environment.withAnimation(
            animated: animated,
            animations: { [weak self] in
                self?.bubbleWindow?.alpha = 0.0
            },
            completion: { [weak self] _ in
                self?.bubbleWindow = nil
                self?.delegate?(.maximized)
            }
        )
    }

    func removeBubbleWindow() {
        bubbleWindow?.alpha = 0.0
        bubbleWindow = nil
    }

    func minimize(animated: Bool) {
        environment.log.prefixed(Self.self).info("Bubble: show application-only bubble")
        defer { delegate?(.minimized) }
        guard let bubbleView = bubbleView else {
            return
        }

        environment.openTelemetry.logger.i(.bubbleShown)
        bubbleView.kind = bubbleKind

        let bubbleWindow = makeBubbleWindow(bubbleView: bubbleView)
        bubbleWindow.tap = { [weak self] in self?.maximize(animated: true) }
        bubbleWindow.alpha = 0.0
        bubbleWindow.isHidden = false
        self.bubbleWindow = bubbleWindow
        if becomesKeyWindow {
            bubbleWindow.makeKeyAndVisible()
        }

        UIView.animate(
            withDuration: animated ? 0.4 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                bubbleWindow.alpha = self.features.contains(.bubbleView) ? 1.0 : 0.0
            }
        )
    }

    private func makeBubbleWindow(bubbleView: BubbleView) -> BubbleWindow {
        if let windowScene = windowScene() {
            return BubbleWindow(
                bubbleView: bubbleView,
                environment: .create(with: environment),
                windowScene: windowScene
            )
        } else {
            return BubbleWindow(
                bubbleView: bubbleView,
                environment: .create(with: environment)
            )
        }
    }

    private func windowScene() -> UIWindowScene? {
        if let windowScene = sceneProvider?.windowScene() {
            return windowScene
        } else {
            let scene = UIApplication.shared
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            return scene as? UIWindowScene
        }
    }
}
