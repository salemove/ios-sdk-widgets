import UIKit

class BubbleWindow: UIWindow {
    var bubbleKind: BubbleKind {
        get { return bubbleView.kind }
        set { bubbleView.kind = newValue }
    }
    var tap: (() -> Void)?

    private let bubbleView: BubbleView
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
        self.bubbleView = bubbleView
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        windowLevel = .statusBar
        rootViewController = BubbleViewController(bubbleView: bubbleView)

        bubbleView.tap = { [weak self] in self?.tap?() }
        bubbleView.pan = { [weak self] in self?.pan($0) }
    }

    private func layout() {
        frame = initialFrame
    }

    private func pan(_ translation: CGPoint) {
        var frame = self.frame
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
            self.frame = frame
        }
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
