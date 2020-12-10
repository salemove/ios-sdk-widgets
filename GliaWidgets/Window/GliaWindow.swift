import UIKit

class GliaWindow: UIWindow {
    enum State {
        case maximized
        case minimized
    }

    private var state: State = .maximized
    private var minimizedView: UIView

    init(minimizedView: UIView) {
        self.minimizedView = minimizedView
        super.init(frame: .zero)
        clipsToBounds = true
        setState(.maximized, animated: false)

        //let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(handlePan(_:)))
        //addGestureRecognizer(panRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(_ state: State, animated: Bool) {
        self.state = state

        switch state {
        case .maximized:
            maximize(animated: animated)
        case .minimized:
            minimize(animated: animated)
        }
    }

    func maximize(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0,
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

        UIView.animate(withDuration: animated ? 0.2 : 0.0,
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
            let origin = CGPoint(x: bounds.width - minimizedView.frame.size.width,
                                 y: bounds.height - minimizedView.frame.size.height)
            let size = minimizedView.frame.size
            return CGRect(origin: origin, size: size)
        }
    }
}
