import UIKit

public enum GliaViewControllerEvent {
    case minimized
    case maximized
}

public protocol GliaViewControllerDelegate: AnyObject {
    func event(_ event: GliaViewControllerEvent)
}

class GliaViewController: UIViewController {
    var bubbleKind: BubbleKind = .userImage(url: nil) {
        didSet { bubbleWindow?.bubbleKind = bubbleKind }
    }

    private let bubbleView: BubbleView?
    private let features: Features

    private var bubbleWindow: BubbleWindow?
    private var sceneProvider: SceneProvider?
    private var animationImageView: UIImageView?

    private weak var delegate: GliaViewControllerDelegate?

    init(
        bubbleView: BubbleView,
        delegate: GliaViewControllerDelegate?,
        features: Features
    ) {
        self.bubbleView = bubbleView
        self.delegate = delegate
        self.features = features

        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(iOS 13.0, *)
    init(
        bubbleView: BubbleView?,
        delegate: GliaViewControllerDelegate?,
        sceneProvider: SceneProvider,
        features: Features
    ) {
        self.bubbleView = bubbleView
        self.delegate = delegate
        self.sceneProvider = sceneProvider
        self.features = features

        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func maximize(animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.4 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                self.bubbleWindow?.alpha = 0.0
            },
            completion: { _ in
                self.bubbleWindow = nil
            }
        )

        delegate?.event(.maximized)
    }

    func minimize(animated: Bool) {
        defer { delegate?.event(.minimized) }

        guard let bubbleView = bubbleView else {
            return
        }

        bubbleView.kind = bubbleKind

        let bubbleWindow = makeBubbleWindow(bubbleView: bubbleView)
        bubbleWindow.tap = { [weak self] in self?.maximize(animated: true) }
        bubbleWindow.alpha = 0.0
        bubbleWindow.isHidden = false
        self.bubbleWindow = bubbleWindow

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

    private func setup() {
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }

    private func makeBubbleWindow(bubbleView: BubbleView) -> BubbleWindow {
        if #available(iOS 13.0, *) {
            if let windowScene = windowScene() {
                return BubbleWindow(
                    bubbleView: bubbleView,
                    windowScene: windowScene
                )
            } else {
                return BubbleWindow(bubbleView: bubbleView)
            }
        } else {
            return BubbleWindow(bubbleView: bubbleView)
        }
    }

    @available(iOS 13.0, *)
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

// MARK: - UIViewControllerTransitioningDelegate

extension GliaViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return GliaViewTransitionController(
            originCenterPoint: bubbleWindow?.center ?? view.center,
            transitionMode: .present
        )
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return GliaViewTransitionController(
            originCenterPoint: bubbleWindow?.center ?? view.center,
            transitionMode: .dismiss
        )
    }
}
