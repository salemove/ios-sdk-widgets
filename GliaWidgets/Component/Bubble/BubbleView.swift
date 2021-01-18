import UIKit

class BubbleView: UIView {
    enum Kind {
        case userImage(url: String?)
    }

    var kind: Kind = .userImage(url: nil) {
        didSet { update(kind) }
    }
    var tap: (() -> Void)?

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
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.4

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)

        update(kind)
    }

    private func layout() {}

    private func update(_ kind: Kind) {
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
}
