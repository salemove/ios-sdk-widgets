import UIKit

class BubbleWindow: UIWindow {
    var bubbleKind: BubbleKind {
        get { return bubbleView.kind }
        set { bubbleView.kind = newValue }
    }
    var tap: (() -> Void)?

    private let environment: Environment
    private let bubbleView: BubbleView
    private let kSize = CGSize(width: 80, height: 80)
    private let kBubbleInset: CGFloat = 10
    private let kEdgeInset: CGFloat = 0
    private var initialFrame: CGRect {
        let bounds = environment.uiApplication.windows().first?.frame ?? environment.uiScreen.bounds()
        let safeAreaInsets = environment.uiApplication.windows().first?.safeAreaInsets ?? .zero
        let origin = CGPoint(x: bounds.width - kSize.width - safeAreaInsets.right - kEdgeInset,
                             y: bounds.height - kSize.height - safeAreaInsets.bottom - kEdgeInset)
        return CGRect(origin: origin, size: kSize)
    }

    @available(iOS 13.0, *)
    init(
        bubbleView: BubbleView,
        environment: Environment,
        windowScene: UIWindowScene
    ) {
        self.bubbleView = bubbleView
        self.environment = environment
        super.init(windowScene: windowScene)
        setup()
        layout()
    }

    init(bubbleView: BubbleView, environment: Environment) {
        self.bubbleView = bubbleView
        self.environment = environment
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        windowLevel = .statusBar
        clipsToBounds = true
        rootViewController = BubbleViewController(bubbleView: bubbleView,
                                                  edgeInset: kBubbleInset)

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
        let boundsInsets = environment.uiApplication.windows().first?.safeAreaInsets ?? .zero
        let bounds = environment.uiScreen.bounds().inset(by: boundsInsets)

        if bounds.contains(insetFrame) {
            self.frame = frame
        }
    }
}

private class BubbleViewController: UIViewController {
    private let bubbleView: BubbleView
    private let edgeInset: CGFloat

    init(bubbleView: BubbleView, edgeInset: CGFloat) {
        self.bubbleView = bubbleView
        self.edgeInset = edgeInset
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(bubbleView)
        bubbleView.autoPinEdgesToSuperviewEdges(
            with: UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset))
    }
}

extension BubbleWindow {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
        var uiApplication: UIKitBased.UIApplication
    }
}
