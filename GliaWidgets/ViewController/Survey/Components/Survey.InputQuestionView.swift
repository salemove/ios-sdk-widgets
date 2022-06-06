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
        let validationError = ValidationErrorView()
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
            title.attributedText = .withRequiredSymbol(
                foregroundColor: .init(hex: style.title.color),
                fontSize: style.title.fontSize,
                fontWeight: style.title.fontWeight,
                isRequired: props.isRequired,
                text: props.title
            )
            textView.text = props.value
            validationError.isHidden = !props.showValidationError
            textView.layer.cornerRadius = props.showValidationError ?
                style.option.highlightedLayer.cornerRadius :
                style.option.normalLayer.cornerRadius
            textView.layer.borderColor = props.showValidationError ?
                UIColor(hex: style.option.highlightedLayer.borderColor).cgColor :
                UIColor(hex: style.option.normalLayer.borderColor).cgColor
            textView.layer.borderWidth = props.showValidationError ?
                style.option.highlightedLayer.borderWidth :
                style.option.normalLayer.borderWidth
            if let backgroundColor = style.background.background {
                textView.backgroundColor = UIColor(hex: backgroundColor)
            }
            textView.font = .systemFont(
                ofSize: style.option.normalText.fontSize,
                weight: .init(rawValue: style.option.normalText.fontWeight)
            )
            textView.textColor = UIColor(hex: style.textColor)
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
            answerContainer: CoreSdkClient.SurveyAnswerContainer? = nil
        ) {
            self.id = id
            self.title = title
            self.value = value
            self.isRequired = isRequired
            self.showValidationError = showValidationError
            self.textDidChange = textDidChange
            self.answerContainer = answerContainer
        }
    }
}

extension Survey.InputQuestionView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        props.textDidChange(textView.text)
    }
}
