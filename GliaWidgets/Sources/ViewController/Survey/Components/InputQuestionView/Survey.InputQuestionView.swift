import UIKit

extension Survey {
    final class InputQuestionView: BaseView {
        var props: Props {
            didSet { render() }
        }

        // MARK: - UI components

        let title = UILabel().make {
            $0.numberOfLines = 0
        }
        lazy var textView = PlaceholderTextView(
            style: .init(
                text: style.option.normalText,
                placeholder: style.placeholder,
                accessibility: .init(isFontScalingEnabled: style.accessibility.isFontScalingEnabled)
            )
        ).make { $0.clipsToBounds = true }
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

        required init() {
            fatalError("init() has not been implemented")
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

            title.textAlignment = style.title.alignment
            title.accessibilityLabel = props.title
            title.accessibilityValue = props.accessibility.titleValue
            textView.accessibilityHint = props.accessibility.fieldHint

            textView.text = props.value
            textView.placeholder = props.placeholder
            validationError.isHidden = !props.showValidationError

            let layerStyle = layerStyle()
            renderLayerStyle(layerStyle)

            let textStyle = textStyle()
            renderTextStyle(textStyle)

            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: textView
            )
        }

        func layerStyle() -> Theme.Layer {
            if textView.isFirstResponder {
                return style.option.selectedLayer
            } else if props.showValidationError {
                return style.option.highlightedLayer
            } else {
                return style.option.normalLayer
            }
        }

        func textStyle() -> Theme.Text {
            if textView.isFirstResponder {
                return style.option.selectedText
            } else if props.showValidationError {
                return style.option.highlightedText
            } else {
                return style.option.normalText
            }
        }

        func renderLayerStyle(_ layer: Theme.Layer) {
            textView.layer.cornerRadius = layer.cornerRadius
            textView.layer.borderColor = layer.borderColor
            textView.layer.borderWidth = layer.borderWidth
            layer.background.unwrap { colorType in
                switch colorType {
                case .fill(let color):
                    textView.backgroundColor = color
                case .gradient(let colors):
                    textView.layer.insertSublayer(makeGradientBackground(colors: colors), at: 0)
                }
            }
        }

        func renderTextStyle(_ text: Theme.Text) {
            textView.applyStyle(.init(
                text: text,
                placeholder: style.placeholder,
                accessibility: .init(isFontScalingEnabled: style.accessibility.isFontScalingEnabled)
            ))
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
        var placeholder: String
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
            placeholder: String = "",
            isRequired: Bool = false,
            showValidationError: Bool = false,
            textDidChange: @escaping (String) -> Void = { _ in },
            answerContainer: CoreSdkClient.SurveyAnswerContainer? = nil,
            accessibility: Accessibility
        ) {
            self.id = id
            self.title = title
            self.value = value
            self.placeholder = placeholder
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

    func textViewDidBeginEditing(_ textView: UITextView) {
        renderLayerStyle(style.option.selectedLayer)
        renderTextStyle(style.option.selectedText)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        render()
    }
}
