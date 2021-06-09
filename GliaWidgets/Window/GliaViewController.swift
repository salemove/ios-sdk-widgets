import UIKit

public enum GliaWindowEvent {
    case minimized
    case maximized
}

public protocol GliaWindowDelegate: AnyObject {
    func event(_ event: GliaWindowEvent)
}

class GliaViewController: UIViewController {
    var bubbleKind: BubbleKind = .userImage(url: nil) {
        didSet { bubbleWindow?.bubbleKind = bubbleKind }
    }

    private enum State {
        case maximized
        case minimized
    }

    private var state: State = .maximized
    private weak var delegate: GliaWindowDelegate?
    private var gliaNavigationController: UINavigationController!
    private let bubbleView: BubbleView
    private var bubbleWindow: BubbleWindow?
    private var animationImageView: UIImageView?

    private var maximizeScreenshot: UIImage? {
        UIApplication.shared.windows.first?.screenshot
    }

    init(bubbleView: BubbleView, delegate: GliaWindowDelegate?) {
        self.bubbleView = bubbleView
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func insertNavigationController(_ navigationController: UINavigationController) {
        self.gliaNavigationController = navigationController
        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.didMove(toParent: self)
    }

    func maximize(animated: Bool) {
        guard let animationImageView = animationImageView else { return }

        bubbleWindow.map { animationImageView.frame = $0.frame }

        animationImageView.image = maximizeScreenshot
        animationImageView.isHidden = false

        UIView.animate(
            withDuration: animated ? 0.4 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                self.bubbleWindow?.alpha = 0.0
                self.animationImageView?.frame = CGRect(origin: .zero, size: self.view.frame.size)
            },
            completion: { _ in
                self.bubbleWindow = nil
                self.animationImageView?.removeFromSuperview()
                self.animationImageView = nil
                self.animationImageView?.isUserInteractionEnabled = false
            }
        )
        setState(.maximized)
    }

    func minimize(animated: Bool) {
        bubbleView.kind = bubbleKind

        let bubbleWindow = BubbleWindow(bubbleView: bubbleView)
        bubbleWindow.tap = { [weak self] in self?.maximize(animated: true) }
        bubbleWindow.alpha = 0.0
        bubbleWindow.isHidden = false
        self.bubbleWindow = bubbleWindow

        let animationImageView = UIImageView()
        animationImageView.frame = CGRect(origin: .zero, size: self.view.frame.size)
        animationImageView.image = maximizeScreenshot
        self.animationImageView = animationImageView
        view.addSubview(animationImageView)

        UIView.animate(
            withDuration: animated ? 0.4 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                bubbleWindow.alpha = 1.0
                animationImageView.frame = bubbleWindow.frame
            },
            completion: { _ in
                animationImageView.isHidden = true
            }
        )
        setState(.minimized)
    }

    private func setup() {
        transitioningDelegate = self
        modalPresentationStyle = .custom
        maximize(animated: false)
    }

    private func setState(_ state: State) {
        self.state = state

        switch state {
        case .maximized:
            delegate?.event(.maximized)
        case .minimized:
            delegate?.event(.minimized)
        }
    }
}

extension GliaViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return BubbleTransitionAnimationController(duration: 0.4, transitionType: .present)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return BubbleTransitionAnimationController(duration: 0.4, transitionType: .dismiss)
    }
}
