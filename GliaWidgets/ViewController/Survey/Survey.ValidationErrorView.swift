import UIKit

extension Survey {
    final class ValidationErrorView: BaseView {
        let validationMessage = UILabel().make {
            $0.numberOfLines = 0
        }
        let validationImage = UIImageView().make {
            $0.image = Asset.surveyValidationError.image
        }
        lazy var validationMessageHStack = UIStackView.make(.horizontal, spacing: 8)(
            validationImage,
            validationMessage
        )

        private let style: Theme.SurveyStyle.ValidationError

        // MARK: - Lifycycle

        init(style: Theme.SurveyStyle.ValidationError) {
            self.style = style
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        override func setup() {
            super.setup()
            addSubview(validationMessageHStack)
            accessibilityLabel = style.accessibility.label
            accessibilityElements = [validationMessageHStack]
            isAccessibilityElement = true

            validationMessage.textColor = .init(hex: style.color)
            validationMessage.font = style.font
            validationMessage.text = style.message

            validationMessageHStack.alignment = .center

            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: validationMessage
            )
        }

        override func defineLayout() {
            super.defineLayout()
            NSLayoutConstraint.activate([
                validationMessageHStack.topAnchor.constraint(equalTo: topAnchor),
                validationMessageHStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                validationMessageHStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                validationMessageHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                validationImage.widthAnchor.constraint(equalToConstant: 16),
                validationImage.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
    }
}
