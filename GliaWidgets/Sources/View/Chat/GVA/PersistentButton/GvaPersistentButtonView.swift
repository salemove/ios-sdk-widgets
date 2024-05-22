import UIKit

final class GvaPersistentButtonView: OperatorChatMessageView {
    var onOptionTapped: ((GvaOption) -> Void)!

    private let viewStyle: GvaPersistentButtonStyle
    private let stackViewLayoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    private let environment: Environment

    init(with style: ChatStyle, environment: Environment) {
        self.viewStyle = style.gliaVirtualAssistant.persistentButton
        self.environment = environment
        super.init(
            with: style.operatorMessageStyle,
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
        case let .gvaPersistentButton(persistentButton):
            let contentView = self.contentView(for: persistentButton)
            appendContentView(contentView, animated: animated)
        default:
            break
        }
    }

    private func contentView(for persistentButton: GvaButton) -> UIView {
        let containerView = ContainerView(style: viewStyle)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = stackViewLayoutMargins
        containerView.addSubview(stackView)
        stackView.layoutInSuperview().activate()

        let textView = ChatTextContentView(
            with: viewStyle.title,
            contentAlignment: .left,
            insets: .zero
        )
        textView.attributedText = persistentButton.content
        stackView.addArrangedSubview(textView)
        setupAccessibilityProperties(for: textView)

        let optionViews: [UIView] = persistentButton.options.compactMap { option in
            let optionView = GvaPersistentButtonOptionView(
                style: viewStyle.button,
                text: option.text
            )
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

extension GvaPersistentButtonView {
    final class ContainerView: BaseView {
        let style: GvaPersistentButtonStyle

        init(style: GvaPersistentButtonStyle) {
            self.style = style
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        override func layoutSubviews() {
            layer.cornerRadius = style.cornerRadius
            layer.borderWidth = style.borderWidth
            layer.borderColor = style.borderColor.cgColor

            switch style.backgroundColor {
            case .fill(let color):
                backgroundColor = color
            case .gradient(let colors):
                makeGradientBackground(
                    colors: colors,
                    cornerRadius: style.cornerRadius
                )
            }
        }
    }
}
