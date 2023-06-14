import UIKit

class AttachmentSourceItemView: UIView {
    var tap: ((AttachmentSourceItemKind) -> Void)?

    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    private let style: AttachmentSourceItemStyle
    private let kContentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    private let kHeight: CGFloat = 44

    init(with style: AttachmentSourceItemStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        titleLabel.text = style.title
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor

        accessibilityTraits = .button
        accessibilityLabel = style.title
        isAccessibilityElement = true

        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: titleLabel
        )

        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.addArrangedSubview(titleLabel)

        if let icon = style.icon {
            let imageView = UIImageView(image: icon)
            imageView.tintColor = style.iconColor
            imageView.clipsToBounds = true
            imageView.contentMode = .right
            stackView.addArrangedSubview(imageView)
        }

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)
    }

    private func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += match(.height, value: kHeight)

        addSubview(stackView)
        constraints += stackView.layoutInSuperview(insets: kContentInsets)
    }

    @objc private func tapped() {
        tap?(style.kind)
    }
}
