import UIKit

enum BubbleKind {
    case userImage(url: String?)
}

class BubbleView: UIView {
    var kind: BubbleKind = .userImage(url: nil) {
        didSet { update(kind) }
    }
    var tap: (() -> Void)?
    var pan: ((CGPoint) -> Void)?

    var innerSmallerFrame: CGRect {
        didSet {
            let xDifference = frame.width - innerSmallerFrame.width
            let yDifference = frame.height - innerSmallerFrame.height

            frame.origin.x = innerSmallerFrame.origin.x - xDifference / 2
            frame.origin.y = innerSmallerFrame.origin.y - yDifference / 2
        }
    }

    private let style: BubbleStyle
    private var userImageView: UserImageView?
    private var badgeView: BadgeView?

    init(with style: BubbleStyle) {
        self.style = style
        self.innerSmallerFrame = CGRect.zero
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

    func adjustInnerFrame(to bounds: CGRect) {
        innerSmallerFrame = frame

        if bounds.width < frame.width {
            let difference = frame.width - bounds.width
            innerSmallerFrame.size.width = bounds.width
            innerSmallerFrame.origin.x += difference / 2
        }
        if bounds.height < frame.height {
            let difference = frame.height - bounds.height
            innerSmallerFrame.size.height = bounds.height
            innerSmallerFrame.origin.y += difference / 2
        }
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

        update(kind)
    }

    private func layout() {}

    private func update(_ kind: BubbleKind) {
        switch kind {
        case .userImage(url: let url):
            guard userImageView == nil else {
                userImageView?.setImage(fromUrl: url, animated: true)
                break
            }
            let userImageView = UserImageView(with: style.userImage)
            userImageView.setImage(fromUrl: url, animated: true)
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
