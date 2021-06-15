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

    private weak var delegate: GliaViewControllerDelegate?
    private let bubbleView: BubbleView
    private var bubbleWindow: BubbleWindow?
    private var animationImageView: UIImageView?

    private var maximizeScreenshot: UIImage? {
        UIApplication.shared.windows.first?.screenshot
    }

    init(bubbleView: BubbleView, delegate: GliaViewControllerDelegate?) {
        self.bubbleView = bubbleView
        self.delegate = delegate
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
        bubbleView.kind = bubbleKind

        let bubbleWindow = BubbleWindow(bubbleView: bubbleView)
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
                bubbleWindow.alpha = 1.0
            }
        )
        delegate?.event(.minimized)
    }

    private func setup() {
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
}
