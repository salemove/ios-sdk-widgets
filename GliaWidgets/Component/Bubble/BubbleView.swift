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

    private let style: BubbleStyle
    private var userImageView: UserImageView?

    public init(with style: BubbleStyle) {
        self.style = style
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

    private func setup() {
        clipsToBounds = false
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 5.0)
        layer.shadowRadius = 3.0
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
