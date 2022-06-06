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
                value.font = .systemFont(ofSize: style.normalText.fontSize, weight: .init(rawValue: style.normalText.fontWeight))
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
                value.font = .systemFont(ofSize: style.highlightedText.fontSize, weight: .init(rawValue: style.highlightedText.fontWeight))
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
                value.font = .systemFont(ofSize: style.selectedText.fontSize, weight: .init(rawValue: style.selectedText.fontWeight))
            }
        }

        // MARK: - Private

        private let style: Theme.SurveyStyle.OptionButton

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}
