import UIKit

final class ChoiceCardOptionView: UIView {
    enum OptionState {
        case normal
        case selected
        case disabled
    }

    var state: OptionState {
        didSet { updateStyle() }
    }

    var tap: (() -> Void)?

    private let text: String?
    private let textLabel = UILabel()
    private let choiceButton = UIButton()
    private let style: Theme.ChoiceCardStyle.Option
    private let viewInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

    init(with style: Theme.ChoiceCardStyle.Option, text: String?) {
        self.style = style
        self.state = .normal
        self.text = text
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = style.normal.background.color
        layer.cornerRadius = style.normal.cornerRadius

        textLabel.text = text
        textLabel.font = style.normal.title.font
        textLabel.textColor = UIColor(hex: style.normal.title.color)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.isAccessibilityElement = false

        choiceButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    private func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints += textLabel.layoutInSuperview(insets: viewInsets)

        addSubview(choiceButton)
        choiceButton.translatesAutoresizingMaskIntoConstraints = false
        constraints += choiceButton.layoutInSuperview()
    }

    private func updateStyle() {
        switch state {
        case .normal:
            applyStyle(style.normal)
        case .selected:
            applyStyle(style.selected)
        case .disabled:
            applyStyle(style.disabled)
        }
        updateAccessibilityProperties()
    }

    private func applyStyle(_ style: Theme.Button) {
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: textLabel
        )

        UIView.transition(with: textLabel, duration: 0.2, options: .transitionCrossDissolve) {
            switch style.background {
            case let .fill(color):
                self.backgroundColor = color
            case let .gradient(colors):
                self.makeGradientBackground(
                    colors: colors,
                    cornerRadius: style.cornerRadius
                )
            }
            self.layer.cornerRadius = style.cornerRadius
            self.textLabel.textColor = UIColor(hex: style.title.color)
            if let borderColor = style.borderColor {
                self.layer.borderColor = UIColor(hex: borderColor).cgColor
                self.layer.borderWidth = style.borderWidth
            }
        }
    }

    @objc private func onTap() {
        tap?()
    }
}

extension ChoiceCardOptionView {
    func updateAccessibilityProperties() {
        choiceButton.accessibilityLabel = text
        switch state {
        case .normal:
            choiceButton.accessibilityValue = style.normal.accessibility.label
        case .selected:
            choiceButton.accessibilityValue = style.selected.accessibility.label
        case .disabled:
            choiceButton.accessibilityValue = style.disabled.accessibility.label
        }
    }
}
