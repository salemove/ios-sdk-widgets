import UIKit

class GliaWindow: UIWindow {
    enum State {
        case maximized
        case minimized
    }

    private var state: State = .maximized
    private var minimizedView: UIView
    private let minimizedSize: CGSize
    private var tapRecognizer: UITapGestureRecognizer?
    private var panRecognizer: UIPanGestureRecognizer?

    init(minimizedView: UIView, minimizedSize: CGSize) {
        self.minimizedView = minimizedView
        self.minimizedSize = minimizedSize
        super.init(frame: .zero)
        clipsToBounds = true
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
            maximize(animated: animated)
            removeGestureRecognizers()
        case .minimized:
            minimize(animated: animated)
            addGestureRecognizers()
        }
    }

    func maximize(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.minimizedView.alpha = 0.0
                        self.frame = self.frame(for: .maximized)
                       }, completion: { _ in
                        self.minimizedView.removeFromSuperview()
                       })
    }

    func minimize(animated: Bool) {
        minimizedView.alpha = 0.0

        addSubview(minimizedView)
        minimizedView.autoPinEdge(toSuperviewEdge: .top)
        minimizedView.autoPinEdge(toSuperviewEdge: .left)

        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.minimizedView.alpha = 1.0
                        self.frame = self.frame(for: .minimized)
                       }, completion: nil)
    }

    private func frame(for state: State) -> CGRect {
        let bounds = UIScreen.main.bounds

        switch state {
        case .maximized:
            return bounds
        case .minimized:
            let origin = CGPoint(x: bounds.width - minimizedSize.width,
                                 y: bounds.height - minimizedSize.height)
            return CGRect(origin: origin,
                          size: minimizedSize)
        }
    }

    private func addGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        self.tapRecognizer = tapRecognizer
        addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.panRecognizer = panRecognizer
        addGestureRecognizer(panRecognizer)
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

        gestureView.center = CGPoint(
            x: gestureView.center.x + translation.x,
            y: gestureView.center.y + translation.y
        )

        gesture.setTranslation(.zero, in: self)
    }
}
