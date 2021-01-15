import UIKit

public enum GliaWindowEvent {
    case minimized
    case maximized
}

public protocol GliaWindowDelegate: class {
    func event(_ event: GliaWindowEvent)
}

class GliaWindow: UIWindow {
    enum State {
        case maximized
        case minimized
    }

    private var state: State = .maximized
    private weak var delegate: GliaWindowDelegate?
    private var minimizedView: UIView
    private let minimizedSize: CGSize
    private let kMinimizedViewEdgeInset: CGFloat = 10
    private let kMinimizedTopInset: CGFloat = 20
    private var tapRecognizer: UITapGestureRecognizer?
    private var panRecognizer: UIPanGestureRecognizer?
    private var minimizedViewFrame: CGRect {
        let origin = CGPoint(x: bounds.width - minimizedSize.width - kMinimizedViewEdgeInset,
                             y: bounds.height - minimizedSize.height - kMinimizedViewEdgeInset - kMinimizedTopInset)
        return CGRect(origin: origin,
                      size: minimizedSize)
    }

    init(delegate: GliaWindowDelegate?, minimizedView: UIView, minimizedSize: CGSize) {
        self.delegate = delegate
        self.minimizedView = minimizedView
        self.minimizedSize = minimizedSize
        super.init(frame: .zero)
        windowLevel = .alert
        setState(.maximized, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(_ state: State, animated: Bool) {
        self.state = state

        switch state {
        case .maximized:
            removeShadow()
            removeGestureRecognizers()
            maximize(animated: animated)
            delegate?.event(.maximized)
        case .minimized:
            minimize(animated: animated)
            delegate?.event(.minimized)
            addGestureRecognizers()
            addShadow()
        }
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
                        self.minimizedView.alpha = 0.0
                       }, completion: { _ in
                        self.minimizedView.removeFromSuperview()
                       })
    }

    func minimize(animated: Bool) {
        endEditing(true)

        minimizedView.alpha = 0.0
        addSubview(minimizedView)
        minimizedView.frame = minimizedViewFrame

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.rootViewController?.view.alpha = 0.0
                        self.minimizedView.alpha = 1.0
                        self.frame = self.frame(for: .minimized)
                       }, completion: nil)
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

    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 5.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.4
    }

    private func removeShadow() {
        layer.shadowOffset = .zero
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.0
    }

    private func addGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        self.tapRecognizer = tapRecognizer
        minimizedView.addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.panRecognizer = panRecognizer
        minimizedView.addGestureRecognizer(panRecognizer)
    }

    private func removeGestureRecognizers() {
        if let tapRecognizer = tapRecognizer {
            removeGestureRecognizer(tapRecognizer)
        }

        if let panRecognizer = panRecognizer {
            removeGestureRecognizer(panRecognizer)
        }

        tapRecognizer = nil
        panRecognizer = nil
    }

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        setState(.maximized, animated: true)
    }

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        guard let gestureView = gesture.view else { return }

        var frame = gestureView.frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y

        let insets = UIEdgeInsets(top: -kMinimizedViewEdgeInset,
                                  left: -kMinimizedViewEdgeInset,
                                  bottom: -kMinimizedViewEdgeInset - kMinimizedTopInset,
                                  right: -kMinimizedViewEdgeInset)
        let insetFrame = frame.inset(by: insets)

        if UIScreen.main.bounds.contains(insetFrame) {
            gestureView.frame = frame
        }

        gesture.setTranslation(.zero, in: self)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard state == .minimized else {
            return super.hitTest(point, with: event)
        }

        if super.hitTest(point, with: event) == minimizedView {
            return minimizedView
        }

        return nil
    }
}
