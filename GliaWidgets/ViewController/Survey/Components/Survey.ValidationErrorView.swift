import UIKit

extension Survey {
    final class ValidationErrorView: View {
        let validationMessage = UILabel().make {
            $0.numberOfLines = 0
            $0.textColor = .red
            $0.font = .boldSystemFont(ofSize: 12)
            $0.text = L10n.Survey.Action.validationError
        }
        let validationImage = UIImageView().make {
            $0.image = Asset.surveyValidationError.image
        }
        lazy var validationMessageHStack = UIStackView.make(.horizontal, spacing: 8)(
            validationImage,
            validationMessage
        )

        override func setup() {
            super.setup()
            addSubview(validationMessageHStack)
            accessibilityLabel = L10n.Survey.Accessibility.Validation.Title.label
            accessibilityElements = [validationMessageHStack]
            isAccessibilityElement = true
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
