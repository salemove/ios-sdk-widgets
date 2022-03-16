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
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.darkGray.cgColor
        }
        let validationError = ValidationErrorView()
        lazy var contentStack = UIStackView.make(.vertical, spacing: 16)(
            title,
            textView,
            validationError
        )

        init(props: Props) {
            self.props = props
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
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                textView.heightAnchor.constraint(equalToConstant: 96)
            ])
        }

        func render() {
            title.attributedText = .withRequiredSymbol(
                isRequired: props.isRequired,
                text: props.title
            )
            textView.text = props.value
            validationError.isHidden = !props.showValidationError
        }
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
