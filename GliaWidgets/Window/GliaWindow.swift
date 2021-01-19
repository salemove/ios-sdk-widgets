import UIKit

public enum GliaWindowEvent {
    case minimized
    case maximized
}

public protocol GliaWindowDelegate: class {
    func event(_ event: GliaWindowEvent)
}

class GliaWindow: UIWindow {
    private enum State {
        case maximized
        case minimized
    }

    private var state: State = .maximized
    private weak var delegate: GliaWindowDelegate?
    private var bubbleWindow: BubbleWindow?
    private var animationImageView: UIImageView?

    private var maximizeScreeshot: UIImage? {
        frame.origin.x = UIScreen.main.bounds.size.width
        isHidden = false
        alpha = 1.0
        let maximizeScreeshot = screenshot
        alpha = 0.0
        isHidden = true
        frame = UIScreen.main.bounds
        return maximizeScreeshot
    }

    init(delegate: GliaWindowDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func maximize(animated: Bool) {
        if let bubbleWindow = bubbleWindow {
            animationImageView?.frame = bubbleWindow.frame
        }

        animationImageView?.image = maximizeScreeshot
        animationImageView?.isHidden = false

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.isHidden = false
                        self.alpha = 1.0
                        self.bubbleWindow?.alpha = 0.0
                        self.animationImageView?.frame = CGRect(origin: .zero, size: self.bounds.size)
                       }, completion: { _ in
                        self.bubbleWindow = nil
                        self.animationImageView?.removeFromSuperview()
                        self.animationImageView = nil
                       })
        setState(.maximized)
    }

    func minimize(using bubbleView: BubbleView, animated: Bool) {
        endEditing(true)

        let bubbleWindow = BubbleWindow(bubbleView: bubbleView)
        bubbleWindow.tap = { [weak self] in self?.maximize(animated: true) }
        bubbleWindow.alpha = 0.0
        bubbleWindow.isHidden = false
        self.bubbleWindow = bubbleWindow

        let animationImageView = UIImageView()
        animationImageView.frame = CGRect(origin: .zero, size: bounds.size)
        animationImageView.image = screenshot
        self.animationImageView = animationImageView
        addSubview(animationImageView)

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        bubbleWindow.alpha = 1.0
                        animationImageView.frame = bubbleWindow.frame
                        self.alpha = 0.0
                       }, completion: { _ in
                        self.isHidden = true
                        animationImageView.isHidden = true
                       })
        setState(.minimized)
    }

    private func setup() {
        windowLevel = .alert
        maximize(animated: false)
    }

    private func layout() {
        frame = UIScreen.main.bounds
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
