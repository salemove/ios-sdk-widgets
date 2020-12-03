import UIKit

class AlertButton: UIButton {
    var tap: (() -> Void)?

    private let style: AlertButtonStyle
    private let kHeight: CGFloat = 40.0
    private let kCornerRadius: CGFloat = 4.0

    public init(with style: AlertButtonStyle) {
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
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: kCornerRadius, height: kCornerRadius)
        ).cgPath
    }

    private func setup() {
        backgroundColor = style.backgroundColor
        clipsToBounds = true

        layer.masksToBounds = false
        layer.cornerRadius = kCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.2

        contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)

        titleLabel?.font = style.titleFont
        titleLabel?.textColor = style.titleColor
        titleLabel?.textAlignment = .center
        setTitle(style.title, for: .normal)

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    private func layout() {
        autoSetDimension(.height, toSize: kHeight)
    }

    @objc private func tapped() {
        tap?()
    }
}
