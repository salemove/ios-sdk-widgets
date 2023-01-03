import UIKit

extension Survey {
    final class CheckboxView: BaseView {

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
        let checkImageView = UIImageView().makeView {
            $0.image = Asset.surveyCheckboxChecked.image
        }
        let value = UILabel().makeView {
            $0.numberOfLines = 0
        }
        lazy var contentStack = UIStackView.make(.horizontal, spacing: 8, distribution: .fillProportionally)(
            imageViewContainer,
            value
        )

        var props: Props { didSet { render() } }

        init(
            props: Props = .init(),
            style: Theme.SurveyStyle.Checkbox,
            textStyle: Theme.Text,
            checkedTintColor: UIColor
        ) {
            self.props = props
            self.style = style
            self.textStyle = textStyle
            self.checkedTintColor = checkedTintColor
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        override func setup() {
            super.setup()

            addSubview(contentStack)
            imageViewContainer.addSubview(imageView)
            imageView.addSubview(checkImageView)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
            addGestureRecognizer(gesture)

            render()

            accessibilityElements = [imageView, value]
            accessibilityTraits = .button
            isAccessibilityElement = true

            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: value
            )
        }

        override func defineLayout() {
            super.defineLayout()

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
                imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
                checkImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                checkImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
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
                checkImageView.image = Asset.surveyCheckboxChecked.image
            case .active:
                checkImageView.image = nil
            case .highlighted:
                checkImageView.image = Asset.surveyCheckboxChecked.image
            }
            value.font = style.title.font
            value.textColor = .init(hex: textStyle.color)
			checkImageView.tintColor = checkedTintColor
        }

        // MARK: - Private

        private let style: Theme.SurveyStyle.Checkbox
        private let textStyle: Theme.Text
        private let checkedTintColor: UIColor

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}
