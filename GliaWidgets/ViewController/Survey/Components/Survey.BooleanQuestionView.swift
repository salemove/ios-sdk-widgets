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
        let validationError = ValidationErrorView()
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
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        func render() {
            let delta = props.options.count - optionsStack.arrangedSubviews.count
            switch delta {
            case 1...:
                var constraints = [NSLayoutConstraint](); defer { NSLayoutConstraint.activate(constraints) }
                (0..<abs(delta)).forEach { _ in
                    let buttonView = ButtonView(style: style.option)
                    constraints.append(buttonView.widthAnchor.constraint(equalToConstant: 48))
                    constraints.append(buttonView.heightAnchor.constraint(equalToConstant: 52))
                    optionsStack.addArrangedSubview(buttonView)
                }
            case ..<0:
                optionsStack.arrangedSubviews.suffix(abs(delta)).forEach { $0.removeFromSuperview() }
            default: break
            }

            title.attributedText = .withRequiredSymbol(
                foregroundColor: .init(hex: style.title.color),
                fontSize: style.title.fontSize,
                fontWeight: style.title.fontWeight,
                isRequired: props.isRequired,
                text: props.title
            )
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
            answerContainer: CoreSdkClient.SurveyAnswerContainer? = nil
        ) {
            self.id = id
            self.title = title
            self.isRequired = isRequired
            self.showValidationError = showValidationError
            self.options = options
            self.selected = selected
            self.answerContainer = answerContainer
        }
    }
}
