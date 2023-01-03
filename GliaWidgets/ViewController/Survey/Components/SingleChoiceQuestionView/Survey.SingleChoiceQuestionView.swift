import SalemoveSDK
import UIKit

extension Survey {
    final class SingleChoiceQuestionView: BaseView {
        var props: Props {
            didSet { render() }
        }

        // MARK: - UI components

        let title = UILabel().make {
            $0.numberOfLines = 0
        }
        let optionsStack = UIStackView.make(.vertical, spacing: 24, distribution: .equalSpacing)()
        lazy var validationError = ValidationErrorView(style: style.error)
        lazy var contentStack = UIStackView.make(.vertical, spacing: 16)(
            title,
            optionsStack,
            validationError
        )

        // MARK: - Lifycycle

        init(
            props: Props,
            style: Theme.SurveyStyle.SingleQuestion
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
            render()
        }

        override func defineLayout() {
            super.defineLayout()
            NSLayoutConstraint.activate([
                contentStack.topAnchor.constraint(equalTo: topAnchor),
                contentStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                contentStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        func render() {
            let delta = optionsStack.arrangedSubviews.count - props.options.count
            switch delta {
            case 0:
                break
            default:
                (0..<abs(delta)).forEach { _ in
                    optionsStack.addArrangedSubview(
                        CheckboxView(
                            style: style.option,
                            textStyle: style.option.title,
                            checkedTintColor: .init(hex: style.tintColor)
                        )
                    )
                }
            }

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
            title.accessibilityValue = props.accessibility.value

            zip(props.options, optionsStack.arrangedSubviews)
                .forEach { opt, view in
                    guard let checkboxView = view as? CheckboxView else { return }
                    checkboxView.props = .init(
                        title: opt.name,
                        state: props.selected == opt ? .selected : .active
                    ) {
                        opt.select(opt)
                    }
                }
            validationError.isHidden = !props.showValidationError
        }

        // MARK: - Private

        private let style: Theme.SurveyStyle.SingleQuestion
    }
}

extension Survey.SingleChoiceQuestionView {
    struct Props: SurveyQuestionPropsProtocol {
        let id: String
        let title: String
        let isRequired: Bool
        var showValidationError: Bool
        var options: [Survey.Option<String>]
        var selected: Survey.Option<String>?
        var answerContainer: CoreSdkClient.SurveyAnswerContainer?
        let accessibility: Accessibility

        var isValid: Bool {
            guard isRequired else { return true }
            return selected != nil
        }

        init(
            id: String,
            title: String,
            isRequired: Bool,
            showValidationError: Bool = false,
            options: [Survey.Option<String>] = [],
            selected: Survey.Option<String>? = nil,
            answerContainer: CoreSdkClient.SurveyAnswerContainer? = nil,
            accessibility: Accessibility
        ) {
            self.id = id
            self.title = title
            self.isRequired = isRequired
            self.showValidationError = showValidationError
            self.options = options
            self.selected = selected
            self.answerContainer = answerContainer
            self.accessibility = accessibility
        }
    }
}
