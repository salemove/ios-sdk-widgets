import UIKit

class GvaPersistentButtonOptionView: BaseView {
    var tap: (() -> Void)?

    private let text: String?
    private let textLabel = UILabel()
    private let choiceButton = UIButton()
    private let viewInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

    init(text: String?) {
        self.text = text
        super.init()
    }

    @available(*, unavailable)
    required init() {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        backgroundColor = .clear
        // TODO: Styling will be done in a subsequent PR
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 4
        textLabel.text = text
        textLabel.font = .font(weight: .regular, size: 12)
        textLabel.textColor = UIColor.black
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.isAccessibilityElement = false

        choiceButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    override func defineLayout() {
        super.defineLayout()
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        heightAnchor.constraint(equalToConstant: 42).isActive = true
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints += textLabel.layoutInSuperview(insets: viewInsets)

        addSubview(choiceButton)
        choiceButton.translatesAutoresizingMaskIntoConstraints = false
        constraints += choiceButton.layoutInSuperview()
    }

    private func applyStyle(_ style: ChoiceCardOptionStateStyle) {
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: textLabel
        )

        UIView.transition(with: textLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.layer.backgroundColor = style.backgroundColor.cgColor
            self.textLabel.textColor = style.textColor
            if let borderColor = style.borderColor {
                self.layer.borderColor = borderColor.cgColor
                self.layer.borderWidth = style.borderWidth
            }
        }
    }

    @objc private func onTap() {
        tap?()
    }
}
