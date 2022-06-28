import SalemoveSDK
import UIKit

extension Survey {
    final class BooleanQuestionView: View {
        var props: Props {
            didSet { render() }
        }

        // MARK: - UI components

        let title = UILabel().make {
            $0.numberOfLines = 0
        }
        let optionsStack = UIStackView.make(.horizontal, spacing: 24)()
        lazy var validationError = ValidationErrorView(style: style.error)
        lazy var contentStack = UIStackView.make(.vertical, spacing: 16)(
            title,
            optionsStack,
            validationError
        )

        init(
            props: Props,
            style: Theme.SurveyStyle.BooleanQuestion
        ) {
            self.props = props
            self.style = style
            super.init()
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
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                contentStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
            ])
        }

        func render() {
            let delta = props.options.count - optionsStack.arrangedSubviews.count
            switch delta {
            case 1...:
                var constraints = [NSLayoutConstraint](); defer { NSLayoutConstraint.activate(constraints) }
                (0..<abs(delta)).forEach { _ in
                    let buttonView = ButtonView(style: style.option)
                    constraints.append(buttonView.widthAnchor.constraint(greaterThanOrEqualToConstant: 48))
                    constraints.append(buttonView.heightAnchor.constraint(equalToConstant: 52))
                    optionsStack.addArrangedSubview(buttonView)
                }
            case ..<0:
                optionsStack.arrangedSubviews.suffix(abs(delta)).forEach { $0.removeFromSuperview() }
            default: break
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
                .forEach { option, view in
                    guard let buttonView = view as? ButtonView else { return }
                    let viewState: ButtonView.State = option == props.selected ? .selected : props.showValidationError ? .highlighted : .active
                    buttonView.props = .init(title: option.name, state: viewState) {
                        option.select(option)
                    }
                }
            optionsStack.addArrangedSubview(UIView())
            validationError.isHidden = !props.showValidationError
        }

        // MARK: - Private

        private let style: Theme.SurveyStyle.BooleanQuestion
    }
}

extension Survey.BooleanQuestionView {
    struct Props: SurveyQuestionPropsProtocol {
        let id: String
        let title: String
        let isRequired: Bool
        var showValidationError: Bool
        var options: [Survey.Option<Bool>]
        var selected: Survey.Option<Bool>?
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
            options: [Survey.Option<Bool>] = [],
            selected: Survey.Option<Bool>? = nil,
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
