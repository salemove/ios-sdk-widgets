import UIKit

extension Survey {
    final class CheckboxView: View {

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

            init(
                title: String = "",
                state: State = .active,
                onSelection: @escaping () -> Void = {}
            ) {
                self.title = title
                self.state = state
                self.onSelection = onSelection
            }
        }

        let imageViewContainer = UIView()
        let imageView = UIImageView().makeView {
            $0.image = Asset.surveyCheckbox.image
        }
        let value = UILabel().makeView {
            $0.numberOfLines = 0
        }
        lazy var contentStack = UIStackView.make(.horizontal, spacing: 8)(
            imageViewContainer,
            value
        )

        var props: Props { didSet { render() } }

        init(
            props: Props = .init(),
            style: Theme.Text
        ) {
            self.props = props
            self.style = style
            super.init()
        }

        override func setup() {
            super.setup()

            addSubview(contentStack)
            imageViewContainer.addSubview(imageView)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
            addGestureRecognizer(gesture)

            render()

            accessibilityElements = [imageView, value]
            accessibilityTraits = .button
            isAccessibilityElement = true
        }

        override func defineLayout() {
            super.defineLayout()

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalToConstant: 24),
                imageView.topAnchor.constraint(equalTo: imageViewContainer.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor),
                imageView.trailingAnchor.constraint(lessThanOrEqualTo: imageViewContainer.trailingAnchor),

                contentStack.topAnchor.constraint(equalTo: topAnchor),
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        func render() {
            value.text = props.title
            accessibilityLabel = props.accessibility.label
            switch props.state {
            case .selected:
                imageView.image = Asset.surveyCheckboxChecked.image
            case .active:
                imageView.image = Asset.surveyCheckbox.image
            case .highlighted:
                imageView.image = Asset.surveyCheckboxChecked.image
            }
            value.font = .systemFont(ofSize: style.fontSize, weight: .init(style.fontWeight))
            value.textColor = .init(hex: style.color)
        }

        // MARK: - Private

        private let style: Theme.Text

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}
