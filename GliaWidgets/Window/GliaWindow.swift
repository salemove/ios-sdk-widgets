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
    private var bubbleView: BubbleView?
    private let kBubbleViewSize = CGSize(width: 60, height: 60)
    private let kBubbleViewEdgeInset: CGFloat = 10
    private let kMinimizedTopInset: CGFloat = 20
    private var panRecognizer: UIPanGestureRecognizer?
    private var initialBubbleViewFrame: CGRect {
        let origin = CGPoint(x: bounds.width - kBubbleViewSize.width - kBubbleViewEdgeInset,
                             y: bounds.height - kBubbleViewSize.height - kBubbleViewEdgeInset - kMinimizedTopInset)
        return CGRect(origin: origin,
                      size: kBubbleViewSize)
    }

    init(delegate: GliaWindowDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func maximize(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.frame = self.frame(for: .maximized)
                        self.rootViewController?.view.alpha = 1.0
                        self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                        self.bubbleView?.alpha = 0.0
                       }, completion: { _ in
                        self.bubbleView?.removeFromSuperview()
                        self.bubbleView = nil
                       })
        setState(.maximized)
    }

    func minimize(using bubbleView: BubbleView, animated: Bool) {
        endEditing(true)

        bubbleView.alpha = 0.0
        bubbleView.frame = initialBubbleViewFrame
        bubbleView.tap = { [weak self] in self?.maximize(animated: true) }
        self.bubbleView = bubbleView
        addSubview(bubbleView)

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        bubbleView.alpha = 1.0
                        self.rootViewController?.view.alpha = 0.0
                        self.frame = self.frame(for: .minimized)
                       }, completion: nil)
        setState(.minimized)
    }

    private func setup() {
        windowLevel = .alert
        maximize(animated: false)
    }

    private func frame(for state: State) -> CGRect {
        var bounds = UIScreen.main.bounds

        switch state {
        case .maximized:
            return bounds
        case .minimized:
            bounds.origin.y = kMinimizedTopInset
            return bounds
        }
    }

    private func setState(_ state: State) {
        self.state = state

        switch state {
        case .maximized:
            removeGestureRecognizers()
            delegate?.event(.maximized)
        case .minimized:
            delegate?.event(.minimized)
            addGestureRecognizers()
        }
    }

    private func addGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.panRecognizer = panRecognizer
        bubbleView?.addGestureRecognizer(panRecognizer)
    }

    private func removeGestureRecognizers() {
        if let panRecognizer = panRecognizer {
            removeGestureRecognizer(panRecognizer)
        }

        panRecognizer = nil
    }

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        guard let gestureView = gesture.view else { return }

        var frame = gestureView.frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y

        let insets = UIEdgeInsets(top: -kBubbleViewEdgeInset,
                                  left: -kBubbleViewEdgeInset,
                                  bottom: -kBubbleViewEdgeInset - kMinimizedTopInset,
                                  right: -kBubbleViewEdgeInset)
        let insetFrame = frame.inset(by: insets)

        if UIScreen.main.bounds.contains(insetFrame) {
            gestureView.frame = frame
        }

        gesture.setTranslation(.zero, in: self)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        switch state {
        case .maximized:
            return super.hitTest(point, with: event)
        case .minimized:
            if super.hitTest(point, with: event) == bubbleView {
                return bubbleView
            } else {
                return nil
            }
        }
    }
}
