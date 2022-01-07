import UIKit

class ActionButton: UIButton {
    var tap: (() -> Void)?

    var title: String? {
        get { return title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }

    private let style: ActionButtonStyle
    private let kHeight: CGFloat = 40.0
    private let kContentInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

    init(with style: ActionButtonStyle) {
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
            cornerRadii: CGSize(
                width: style.cornerRaidus ?? 0.0,
                height: style.cornerRaidus ?? 0.0
            )
        ).cgPath
    }

    private func setup() {
        backgroundColor = style.backgroundColor
        contentEdgeInsets = kContentInsets
        clipsToBounds = true

        layer.masksToBounds = false

        layer.cornerRadius = style.cornerRaidus ?? 0.0

        layer.borderColor = style.borderColor?.cgColor
        layer.borderWidth = style.borderWidth ?? 0.0

        layer.shadowColor = style.shadowColor?.cgColor
        layer.shadowOffset = style.shadowOffset ?? .zero
        layer.shadowOpacity = style.shadowOpacity ?? (style.backgroundColor == .clear ? 0.0 : 0.2)
        layer.shadowRadius = style.shadowRadius ?? 0.0

        titleLabel?.font = style.titleFont
        setTitleColor(style.titleColor, for: .normal)
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
