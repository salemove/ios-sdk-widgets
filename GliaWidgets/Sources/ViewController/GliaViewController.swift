import UIKit

/// Defines the events related to the Glia view controller's state.
public enum GliaViewControllerEvent {
    /// Indicates that the Glia view controller has been minimized.
    case minimized

    /// Indicates that the Glia view controller has been maximized.
    case maximized
}

class GliaViewController: UIViewController {
    var bubbleKind: BubbleKind {
        get { bubblePresenter.bubbleKind }
        set { bubblePresenter.bubbleKind = newValue }
    }

    private(set) var sceneProvider: SceneProvider?
    private let bubblePresenter: BubblePresenter

    init(
        bubbleView: BubbleView?,
        delegate: ((GliaViewControllerEvent) -> Void)?,
        sceneProvider: SceneProvider? = .none,
        features: Features,
        environment: Environment
    ) {
        self.sceneProvider = sceneProvider
        self.bubblePresenter = BubblePresenter(
            bubbleView: bubbleView,
            delegate: delegate,
            sceneProvider: sceneProvider,
            becomesKeyWindow: true,
            features: features,
            environment: environment
        )
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setVisitorHoldState(isOnHold: Bool) {
        bubblePresenter.setVisitorHoldState(isOnHold: isOnHold)
    }

    func maximize(animated: Bool) {
        bubblePresenter.maximize(animated: animated)
    }

    func removeBubbleWindow() {
        bubblePresenter.removeBubbleWindow()
    }

    func minimize(animated: Bool) {
        bubblePresenter.minimize(animated: animated)
    }

    private func setup() {
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
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
            originCenterPoint: bubblePresenter.bubbleWindow?.center ?? view.center,
            transitionMode: .present
        )
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return GliaViewTransitionController(
            originCenterPoint: bubblePresenter.bubbleWindow?.center ?? view.center,
            transitionMode: .dismiss
        )
    }
}
