import UIKit

class BubbleWindow: UIWindow {
    var tap: (() -> Void)?

    private let bubbleView: BubbleView
    private let kSize = CGSize(width: 60, height: 60)
    private let kEdgeInset: CGFloat = 10

    init(bubbleView: BubbleView) {
        self.bubbleView = bubbleView
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        windowLevel = .alert

        bubbleView.tap = { [weak self] in self?.tap?() }

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        addGestureRecognizer(panRecognizer)
    }

    private func layout() {
        let screenBounds = UIScreen.main.bounds
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        let origin = CGPoint(x: screenBounds.width - kSize.width - safeAreaInsets.right - kEdgeInset,
                             y: screenBounds.height - kSize.height - safeAreaInsets.bottom - kEdgeInset)
        frame = CGRect(origin: origin, size: kSize)

        addSubview(bubbleView)
        bubbleView.frame = CGRect(origin: .zero, size: frame.size)
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
