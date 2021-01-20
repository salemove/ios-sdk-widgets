import UIKit

class BubbleWindow: UIWindow {
    var tap: (() -> Void)?

    private let kSize = CGSize(width: 60, height: 60)
    private let kEdgeInset: CGFloat = 10
    private var initialFrame: CGRect {
        let bounds = UIApplication.shared.windows.first?.frame ?? UIScreen.main.bounds
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        let origin = CGPoint(x: bounds.width - kSize.width - safeAreaInsets.right - kEdgeInset,
                             y: bounds.height - kSize.height - safeAreaInsets.bottom - kEdgeInset)
        return CGRect(origin: origin, size: kSize)
    }

    init(bubbleView: BubbleView) {
        super.init(frame: .zero)
        setup(with: bubbleView)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(with bubbleView: BubbleView) {
        windowLevel = .statusBar
        rootViewController = BubbleViewController(bubbleView: bubbleView)

        bubbleView.tap = { [weak self] in self?.tap?() }

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        addGestureRecognizer(panRecognizer)
    }

    private func layout() {
        frame = initialFrame
    }

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        guard let gestureView = gesture.view else { return }

        var frame = gestureView.frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y

        let insets = UIEdgeInsets(top: -kEdgeInset,
                                  left: -kEdgeInset,
                                  bottom: -kEdgeInset,
                                  right: -kEdgeInset)
        let insetFrame = frame.inset(by: insets)
        let boundsInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        let bounds = UIScreen.main.bounds.inset(by: boundsInsets)

        if bounds.contains(insetFrame) {
            gestureView.frame = frame
        }

        gesture.setTranslation(.zero, in: self)
    }
}

private class BubbleViewController: UIViewController {
    private let bubbleView: BubbleView

    init(bubbleView: BubbleView) {
        self.bubbleView = bubbleView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        self.view = bubbleView
    }
}
