import UIKit

enum BubbleKind {
    case userImage(url: String?)
    case view(UIView)
}

class BubbleView: BaseView {
    var kind: BubbleKind = .userImage(url: nil) {
        didSet { update(kind) }
    }

    var isVisitorOnHold: Bool = false {
        didSet {
            if isVisitorOnHold {
                showOnHoldView()
            } else {
                hideOnHoldView()
            }

            setAccessibilityIdentifier()
        }
    }

    var tap: (() -> Void)?
    var pan: ((CGPoint) -> Void)?

    private let style: BubbleStyle
    private var userImageView: UserImageView?
    private var badgeView: BadgeView?
    private let onHoldView: OnHoldOverlayView
    private let environment: Environment

    init(
        with style: BubbleStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        self.onHoldView = OnHoldOverlayView(
            environment: .init(gcd: environment.gcd),
            style: style.onHoldOverlay
        )
        self.onHoldView.clipsToBounds = true

        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        let cornerRadius = frame.size.height / 2
        layer.cornerRadius = cornerRadius
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        ).cgPath

        onHoldView.frame = userImageView?.bounds ?? .zero
        onHoldView.layer.cornerRadius = cornerRadius
    }

    func showOnHoldView() {
        onHoldView.removeFromSuperview()
        // In case of badge-view being shown
        // place on-hold view under it.
        if let badgeView {
            insertSubview(onHoldView, belowSubview: badgeView)
        } else {
            addSubview(onHoldView)
        }

    }

    func hideOnHoldView() {
        onHoldView.removeFromSuperview()
    }

    func setBadge(itemCount: Int) {
        guard let style = style.badge else { return }

        if itemCount <= 0 {
            badgeView?.removeFromSuperview()
            badgeView = nil
        } else {
            if badgeView == nil {
                let badgeView = BadgeView(with: style)
                self.badgeView = badgeView
                addSubview(badgeView)
                badgeView.translatesAutoresizingMaskIntoConstraints = false
                var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
                constraints += badgeView.topAnchor.constraint(equalTo: topAnchor)
                constraints += badgeView.trailingAnchor.constraint(equalTo: trailingAnchor)
            }
        }
        badgeView?.newItemCount = itemCount
    }

    override func setup() {
        super.setup()
        clipsToBounds = false
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.4

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        addGestureRecognizer(panRecognizer)
        isAccessibilityElement = true
        accessibilityTraits = [.button]
        accessibilityLabel = style.accessibility.label
        accessibilityHint = style.accessibility.hint
        setAccessibilityIdentifier()

        update(kind)
    }

    private func update(_ kind: BubbleKind) {
        switch kind {
        case .userImage(url: let url):
            guard let userImageView = userImageView else {
                let userImageView = UserImageView(
                    with: style.userImage,
                    environment: .init(
                        data: environment.data,
                        uuid: environment.uuid,
                        gcd: environment.gcd,
                        imageViewCache: environment.imageViewCache
                    )
                )
                userImageView.setOperatorImage(fromUrl: url, animated: true)
                self.userImageView = userImageView
                setView(userImageView)
                return
            }
            userImageView.setOperatorImage(fromUrl: url, animated: true)
            setView(userImageView)
        case .view(let customView):
            setView(customView)
        }
    }

    private func setView(_ view: UIView) {
        subviews.first?.removeFromSuperview()
        view.isUserInteractionEnabled = false
        // Insert view at the zero index
        // to be under other views, like on-hold
        // and unread-count views.
        insertSubview(view, at: 0)
        view.layoutInSuperview().activate()
    }

    private func setAccessibilityIdentifier() {
        accessibilityIdentifier = isVisitorOnHold ? "on_hold_bubble_view" : "bubble_view"
    }

    @objc private func tapped() {
        tap?()
    }

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        guard gesture.view != nil else { return }
        pan?(translation)
        gesture.setTranslation(.zero, in: self)
    }
}

extension BubbleView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
    }
}
