import UIKit

final class GvaPersistentButtonView: OperatorChatMessageView {
    var onOptionTapped: ((GvaOption) -> Void)!

    private let stackViewLayoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    private let environment: Environment

    init(with style: ChoiceCardStyle, environment: Environment) {
        self.environment = environment
        super.init(
            with: style,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                uiScreen: environment.uiScreen
            )
        )
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func appendContent(_ content: ChatMessageContent, animated: Bool) {
        switch content {
        case let .gvaPersistentButton(choiceCard):
            let contentView = self.contentView(for: choiceCard)
            appendContentView(contentView, animated: animated)
        default:
            break
        }
    }

    private func contentView(for persistentButton: GvaButton) -> UIView {
        let containerView = UIView()
        // TODO: Styling will be done in a subsequent PR
        containerView.backgroundColor = UIColor(red: 0.953, green: 0.953, blue: 0.953, alpha: 1)
        containerView.layer.cornerRadius = 8.49
        containerView.layer.borderWidth = 2
        // TODO: Styling will be done in a subsequent PR
        containerView.layer.borderColor = UIColor.clear.cgColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = stackViewLayoutMargins
        containerView.addSubview(stackView)
        stackView.layoutInSuperview().activate()

        let tempChatTextContentStyle: ChatTextContentStyle = .init(
            textFont: .font(weight: .regular, size: 16),
            textColor: .black,
            backgroundColor: .clear
        )
        let textView = ChatTextContentView(
            with: tempChatTextContentStyle,
            contentAlignment: .left,
            insets: .zero
        )
        textView.attributedText = persistentButton.content
        stackView.addArrangedSubview(textView)
        setupAccessibilityProperties(for: textView)

        let optionViews: [UIView] = persistentButton.options.compactMap { option in
            let optionView = GvaPersistentButtonOptionView(text: option.text)
            optionView.tap = { [weak self] in
                self?.onOptionTapped(option)
            }
            return optionView
        }
        stackView.addArrangedSubviews(optionViews)

        return containerView
    }
}

extension GvaPersistentButtonView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiScreen: UIKitBased.UIScreen
    }
}

extension GvaPersistentButtonView {
    func setupAccessibilityProperties(for imageView: ImageView) {
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "placeholder" // Will be implemented in another PR
    }

    func setupAccessibilityProperties(for textView: ChatTextContentView) {
        textView.accessibilityLabel = textView.text
        textView.isAccessibilityElement = true
    }
}
