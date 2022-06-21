import UIKit

class ChoiceCardOptionView: UIView {
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
    private let style: ChoiceCardOptionStyle
    private let kInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

    init(with style: ChoiceCardOptionStyle, text: String?) {
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
        backgroundColor = .clear
        layer.backgroundColor = style.normal.backgroundColor.cgColor
        layer.cornerRadius = 4

        textLabel.text = text
        textLabel.font = style.normal.textFont
        textLabel.textColor = style.normal.textColor
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.isAccessibilityElement = false

        choiceButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    private func layout() {
        addSubview(textLabel)
        textLabel.autoPinEdgesToSuperviewEdges(with: kInsets)

        addSubview(choiceButton)
        choiceButton.autoPinEdgesToSuperviewEdges()
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
                self.layer.borderWidth = 1
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
            choiceButton.accessibilityValue = style.normal.accessibility.value
        case .selected:
            choiceButton.accessibilityValue = style.selected.accessibility.value
        case .disabled:
            choiceButton.accessibilityValue = style.disabled.accessibility.value
        }
    }
}
