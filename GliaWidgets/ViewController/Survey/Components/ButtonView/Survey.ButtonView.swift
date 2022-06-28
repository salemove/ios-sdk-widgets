import UIKit

extension Survey {
    final class ButtonView: View {

        enum State {
            case active, highlighted, selected
        }

        struct Props {
            let title: String
            let state: State
            let onSelection: () -> Void

            var accessibility: Accessibility {
                var label: String {
                    switch state {
                    case .selected:
                        return L10n.Survey.Accessibility.Question.OptionButton.Selected.label.withButtonTitle(title)
                    case .active, .highlighted:
                        return L10n.Survey.Accessibility.Question.OptionButton.Unselected.label.withButtonTitle(title)
                    }
                }
                return .init(label: label)
            }
        }

        let value = UILabel().makeView {
            $0.textAlignment = .center
            $0.clipsToBounds = true
        }

        var props: Props { didSet { render() } }

        init(
            props: Props = .init(title: "", state: .active, onSelection: {}),
            style: Theme.SurveyStyle.OptionButton
        ) {
            self.props = props
            self.style = style
            super.init()
        }

        override func setup() {
            super.setup()

            addSubview(value)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
            addGestureRecognizer(gesture)

            render()
            isAccessibilityElement = true
            accessibilityTraits = .button

            value.font = style.font
            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: value
            )
        }

        override func defineLayout() {
            super.defineLayout()
            NSLayoutConstraint.activate([
                value.topAnchor.constraint(equalTo: topAnchor, constant: 1),
                value.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
                value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
                value.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1)
            ])
        }

        func render() {
            value.text = props.title
            updateUi()
        }

        func updateUi() {
            accessibilityLabel = props.accessibility.label
            switch props.state {
            case .active:
                value.layer.cornerRadius = style.normalLayer.cornerRadius
                value.layer.borderWidth = style.normalLayer.borderWidth
                value.layer.borderColor = UIColor(hex: style.normalLayer.borderColor).cgColor
                if let hex = style.normalLayer.background {
                    value.backgroundColor = UIColor(hex: hex)
                } else {
                    value.backgroundColor = .clear
                }
                value.textColor = .init(hex: style.normalText.color)
                value.font = style.normalText.font
            case .highlighted:
                value.layer.cornerRadius = style.highlightedLayer.cornerRadius
                value.layer.borderWidth = style.highlightedLayer.borderWidth
                value.layer.borderColor = UIColor(hex: style.highlightedLayer.borderColor).cgColor
                if let hex = style.highlightedLayer.background {
                    value.backgroundColor = UIColor(hex: hex)
                } else {
                    value.backgroundColor = .clear
                }
                value.textColor = .init(hex: style.highlightedText.color)
                value.font = style.highlightedText.font
            case .selected:
                value.layer.cornerRadius = style.selectedLayer.cornerRadius
                value.layer.borderWidth = style.selectedLayer.borderWidth
                value.layer.borderColor = UIColor(hex: style.selectedLayer.borderColor).cgColor
                if let hex = style.selectedLayer.background {
                    value.backgroundColor = UIColor(hex: hex)
                } else {
                    value.backgroundColor = .clear
                }
                value.textColor = .init(hex: style.selectedText.color)
                value.font = style.selectedText.font
            }
        }

        // MARK: - Private

        private let style: Theme.SurveyStyle.OptionButton

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}
