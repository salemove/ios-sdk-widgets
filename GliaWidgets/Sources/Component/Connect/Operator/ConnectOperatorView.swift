import UIKit

final class ConnectOperatorView: BaseView {
    enum Size {
        case normal
        case large

        var width: CGFloat {
            switch self {
            case .normal:
                return 80
            case .large:
                return 120
            }
        }

        var height: CGFloat {
            switch self {
            case .normal:
                return 80
            case .large:
                return 120
            }
        }
    }

    let imageView: UserImageView

    var isVisitorOnHold: Bool = false {
        didSet {
            if isVisitorOnHold {
                showOnHoldView()
            } else {
                hideOnHoldView()
            }
        }
    }

    private let style: ConnectOperatorStyle
    private var animationView: ConnectAnimationView?
    private var onHoldView: OnHoldOverlayView?

    private var size: Size = .normal
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private let kAnimationViewSize: CGFloat = 142
    private let environment: Environment

    init(
        with style: ConnectOperatorStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        self.imageView = UserImageView(
            with: style.operatorImage,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func setup() {
        super.setup()
        isAccessibilityElement = true
        accessibilityTraits = .image
        accessibilityLabel = style.accessibility.label
        accessibilityHint = style.accessibility.hint
    }

    override func defineLayout() {
        super.defineLayout()

        addSubview(imageView)
        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
            imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
            imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
            imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
        }
        widthConstraint = imageView.autoSetDimension(.width, toSize: size.width)
        heightConstraint = imageView.autoSetDimension(.height, toSize: size.height)
        imageView.autoCenterInSuperview()
    }

    func setSize(_ size: Size, animated: Bool) {
        self.size = size
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.widthConstraint?.constant = size.width
            self.heightConstraint?.constant = size.height
            self.layoutIfNeeded()
        }
    }

    func startAnimating(animated: Bool) {
        guard animationView == nil else { return }

        let animationView = ConnectAnimationView(
            color: style.animationColor,
            size: kAnimationViewSize
        )
        self.animationView = animationView

        insertSubview(animationView, at: 0)
        animationView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
        animationView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        animationView.autoCenterInSuperview()
        animationView.autoSetDimensions(to: .init(width: kAnimationViewSize, height: kAnimationViewSize))
        animationView.startAnimating()
    }

    func stopAnimating(animated: Bool) {
        animationView?.removeFromSuperview()
        animationView = nil
    }

    func showOnHoldView() {
        onHoldView?.removeFromSuperview()

        let onHoldView = OnHoldOverlayView(style: style.onHoldOverlay)
        self.onHoldView = onHoldView

        imageView.addSubview(onHoldView)
        onHoldView.autoPinEdgesToSuperviewEdges()
    }

    func hideOnHoldView() {
        onHoldView?.removeFromSuperview()
        onHoldView = nil
    }
}

extension ConnectOperatorView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
    }
}
