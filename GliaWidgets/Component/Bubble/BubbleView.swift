import UIKit

enum BubbleKind {
    case userImage(url: String?)
}

class BubbleView: UIView {
    var kind: BubbleKind = .userImage(url: nil) {
        didSet { update(kind) }
    }

    var isVisitorOnHold: Bool = false {
        didSet {
            isVisitorOnHold
                ? showOnHoldView()
                : hideOnHoldView()
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
        onHoldView.autoPinEdgesToSuperviewEdges()
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
                badgeView.autoPinEdge(.top, to: .top, of: self)
                badgeView.autoPinEdge(.right, to: .right, of: self)
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
        accessibilityLabel = "Operator Avatar"
        accessibilityHint = "Deactivates minimize."

        update(kind)
    }

    private func layout() {}

    private func update(_ kind: BubbleKind) {
        switch kind {
        case .userImage(url: let url):
            guard userImageView == nil else {
                userImageView?.setOperatorImage(fromUrl: url, animated: true)
                break
            }
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
        }
    }

    private func setView(_ view: UIView) {
        subviews.first?.removeFromSuperview()
        view.isUserInteractionEnabled = false

        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
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
