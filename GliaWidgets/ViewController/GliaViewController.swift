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
    private var sceneProvider: SceneProvider?
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

    @available(iOS 13.0, *)
    init(
        bubbleView: BubbleView,
        delegate: GliaViewControllerDelegate?,
        sceneProvider: SceneProvider
    ) {
        self.bubbleView = bubbleView
        self.delegate = delegate
        self.sceneProvider = sceneProvider
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

        let bubbleWindow = makeBubbleWindow()
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
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    private func makeBubbleWindow() -> BubbleWindow {
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
