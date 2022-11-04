import UIKit

extension Survey {
    final class InputQuestionView: View {
        var props: Props {
            didSet { render() }
        }

        // MARK: - UI components

        let title = UILabel().make {
            $0.numberOfLines = 0
        }
        let textView = UITextView().make {
            $0.clipsToBounds = true
        }
        lazy var validationError = ValidationErrorView(style: style.error)
        lazy var contentStack = UIStackView.make(.vertical, spacing: 16)(
            title,
            textView,
            validationError
        )

        init(
            props: Props,
            style: Theme.SurveyStyle.InputQuestion
        ) {
            self.props = props
            self.style = style
            super.init()
        }

        override func setup() {
            super.setup()
            addSubview(contentStack)
            textView.delegate = self
            render()
        }

        override func defineLayout() {
            super.defineLayout()
            NSLayoutConstraint.activate([
                contentStack.topAnchor.constraint(equalTo: topAnchor),
                contentStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                contentStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                textView.heightAnchor.constraint(equalToConstant: 96)
            ])
        }

        func render() {
            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: title
            )
            title.attributedText = .withRequiredSymbol(
                foregroundColor: .init(hex: style.title.color),
                font: style.title.font,
                isRequired: props.isRequired,
                text: props.title
            )

            title.accessibilityLabel = props.title
            title.accessibilityValue = props.accessibility.titleValue
            textView.accessibilityHint = props.accessibility.fieldHint

            textView.text = props.value
            validationError.isHidden = !props.showValidationError
            textView.layer.cornerRadius = props.showValidationError ?
                style.option.highlightedLayer.cornerRadius :
                style.option.normalLayer.cornerRadius
            textView.layer.borderColor = props.showValidationError ?
                style.option.highlightedLayer.borderColor :
                style.option.normalLayer.borderColor
            textView.layer.borderWidth = props.showValidationError ?
                style.option.highlightedLayer.borderWidth :
                style.option.normalLayer.borderWidth
            if let backgroundColor = style.background.background {
                switch backgroundColor {
                case .fill(let color):
                    textView.backgroundColor = color
                case .gradient(let colors):
                    textView.layer.insertSublayer(makeGradientBackground(colors: colors), at: 0)
                }
            }
            textView.textColor = UIColor(hex: style.text.color)
            textView.font = style.text.font

            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: textView
            )
        }

        // MARK: - Private

        private let style: Theme.SurveyStyle.InputQuestion
    }
}

extension Survey.InputQuestionView {
    struct Props: Survey.QuestionPropsProtocol {
        let id: String
        var title: String
        var value: String
        var isRequired: Bool
        var showValidationError: Bool
        var textDidChange: (String) -> Void
        var answerContainer: CoreSdkClient.SurveyAnswerContainer?
        let accessibility: Accessibility

        var isValid: Bool {
            guard isRequired else { return true }
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }

        init(
            id: String,
            title: String,
            value: String = "",
            isRequired: Bool = false,
            showValidationError: Bool = false,
            textDidChange: @escaping (String) -> Void = { _ in },
            answerContainer: CoreSdkClient.SurveyAnswerContainer? = nil,
            accessibility: Accessibility
        ) {
            self.id = id
            self.title = title
            self.value = value
            self.isRequired = isRequired
            self.showValidationError = showValidationError
            self.textDidChange = textDidChange
            self.answerContainer = answerContainer
            self.accessibility = accessibility
        }
    }
}

extension Survey.InputQuestionView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        props.textDidChange(textView.text)
    }
}
