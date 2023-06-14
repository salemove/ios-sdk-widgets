import UIKit

enum BubbleKind {
    case userImage(url: String?)
    case view(UIView)
}

class BubbleView: UIView {
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
    private var onHoldView: OnHoldOverlayView?
    private let environment: Environment

    init(
        with style: BubbleStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }

    func showOnHoldView() {
        onHoldView?.removeFromSuperview()

        guard
            let userImageView = userImageView
        else { return }

        let onHoldView = OnHoldOverlayView(style: style.onHoldOverlay)
        self.onHoldView = onHoldView

        userImageView.addSubview(onHoldView)
        onHoldView.layoutInSuperview().activate()
    }

    func hideOnHoldView() {
        onHoldView?.removeFromSuperview()
        onHoldView = nil
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

    private func setup() {
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

    private func layout() {}

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

        addSubview(view)
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
