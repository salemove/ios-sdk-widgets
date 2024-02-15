import UIKit

class GvaPersistentButtonOptionView: BaseView {
    static let height: CGFloat = 42

    var tap: (() -> Void)?

    private let text: String?
    private let textLabel = UILabel()
    private let choiceButton = UIButton()
    private let viewInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    private let style: GvaPersistentButtonStyle.ButtonStyle

    init(
        style: GvaPersistentButtonStyle.ButtonStyle,
        text: String?
    ) {
        self.style = style
        self.text = text
        super.init()
    }

    @available(*, unavailable)
    required init() {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        isAccessibilityElement = true
        accessibilityLabel = text
        accessibilityTraits = .button
        layer.cornerRadius = style.cornerRadius
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor

        textLabel.text = text
        textLabel.font = style.textFont
        textLabel.textColor = style.textColor
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.isAccessibilityElement = false

        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: textLabel
        )

        choiceButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    override func defineLayout() {
        super.defineLayout()
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        heightAnchor.constraint(greaterThanOrEqualToConstant: 42).isActive = true
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints += textLabel.layoutInSuperview(insets: viewInsets)

        addSubview(choiceButton)
        choiceButton.translatesAutoresizingMaskIntoConstraints = false
        constraints += choiceButton.layoutInSuperview()
    }

    override func layoutSubviews() {
        switch style.backgroundColor {
        case .fill(let color):
            backgroundColor = color
        case .gradient(let colors):
            makeGradientBackground(
                colors: colors,
                cornerRadius: style.cornerRadius
            )
        }
    }

    @objc private func onTap() {
        tap?()
    }
}
