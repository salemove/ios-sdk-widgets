import UIKit

extension Survey {
    final class ButtonView: BaseView {

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
                        return Localization.Survey.Question.OptionButton.Selected.Accessibility.label
                            .withButtonTitle(title)
                    case .active, .highlighted:
                        return Localization.Survey.Question.OptionButton.Unselected.Accessibility.label
                            .withButtonTitle(title)
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

        required init() {
            fatalError("init() has not been implemented")
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
                value.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                value.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                value.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
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
                updateActiveState()
            case .highlighted:
                updateHighlightedState()
            case .selected:
                updateSelectedState()
            }
        }

        func updateActiveState() {
            value.layer.cornerRadius = style.normalLayer.cornerRadius
            value.layer.borderWidth = style.normalLayer.borderWidth
            value.layer.borderColor = style.normalLayer.borderColor
            value.textColor = .init(hex: style.normalText.color)
            value.font = style.normalText.font
            if let hex = style.normalLayer.background {
                switch hex {
                case .fill(let color):
                    value.backgroundColor = color
                case .gradient(let colors):
                    makeGradientBackground(
                        colors: colors,
                        cornerRadius: style.normalLayer.cornerRadius
                    )
                }
            } else {
                value.backgroundColor = .clear
            }
        }

        func updateSelectedState() {
            value.layer.cornerRadius = style.selectedLayer.cornerRadius
            value.layer.borderWidth = style.selectedLayer.borderWidth
            value.layer.borderColor = style.selectedLayer.borderColor
            value.textColor = .init(hex: style.selectedText.color)
            value.font = style.selectedText.font
            if let hex = style.selectedLayer.background {
                switch hex {
                case .fill(let color):
                    value.backgroundColor = color
                case .gradient(let colors):
                    makeGradientBackground(
                        colors: colors,
                        cornerRadius: style.selectedLayer.cornerRadius
                    )
                }
            } else {
                value.backgroundColor = .clear
            }
        }

        func updateHighlightedState() {
            value.layer.cornerRadius = style.highlightedLayer.cornerRadius
            value.layer.borderWidth = style.highlightedLayer.borderWidth
            value.layer.borderColor = style.highlightedLayer.borderColor
            value.textColor = .init(hex: style.highlightedText.color)
            value.font = style.highlightedText.font
            if let hex = style.highlightedLayer.background {
                switch hex {
                case .fill(let color):
                    value.backgroundColor = color
                case .gradient(let colors):
                    makeGradientBackground(
                        colors: colors,
                        cornerRadius: style.highlightedLayer.cornerRadius
                    )
                }
            } else {
                value.backgroundColor = .clear
            }
        }

        // MARK: - Private

        private let style: Theme.SurveyStyle.OptionButton

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}
