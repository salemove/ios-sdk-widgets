import UIKit

final class ChoiceCardView: OperatorChatMessageView {
    var onOptionTapped: ((ChatChoiceCardOption) -> Void)!

    private let viewStyle: ChoiceCardStyle
    private let kLayoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    private let kImageHeight: CGFloat = 200.0

    private let environment: Environment

    init(with style: ChoiceCardStyle, environment: Environment) {
        viewStyle = style
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
        case .choiceCard(let choiceCard):
            let contentView = self.contentView(for: choiceCard)
            appendContentView(contentView, animated: animated)
        default:
            break
        }
    }

    private func contentView(for choiceCard: ChoiceCard) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = viewStyle.backgroundColor
        containerView.layer.cornerRadius = viewStyle.cornerRadius
        containerView.layer.borderWidth = viewStyle.borderWidth
        containerView.layer.borderColor = viewStyle.frameColor.cgColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = kLayoutMargins
        containerView.addSubview(stackView)
        stackView.layoutInSuperview().activate()

        if let imageUrl = choiceCard.imageUrl {
            let imageView = ImageView(
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache
                )
            )
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            imageView.match(.height, value: kImageHeight).activate()
            imageView.setImage(from: imageUrl, animated: true)
            stackView.addArrangedSubview(imageView)
            setupAccessibilityProperties(for: imageView)
        }

        let textView = ChatTextContentView(
            with: style.text,
            contentAlignment: .left,
            insets: .zero
        )
        textView.text = choiceCard.text
        stackView.addArrangedSubview(textView)

        guard let options = choiceCard.options else { return containerView }

        let optionViews: [UIView] = options.compactMap { option in
            let optionView = ChoiceCardOptionView(with: viewStyle.choiceOption, text: option.text)

            if let selectedValue = choiceCard.selectedOption {
                optionView.state = option.value == selectedValue
                    ? .selected
                    : .disabled
            } else if choiceCard.isActive {
                optionView.state = .normal
                optionView.tap = { self.onOptionTapped(option) }
            } else {
                optionView.state = .disabled
            }

            return optionView
        }
        stackView.addArrangedSubviews(optionViews)

        return containerView
    }
}

extension ChoiceCardView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiScreen: UIKitBased.UIScreen
    }
}

extension ChoiceCardView {
    func setupAccessibilityProperties(for imageView: ImageView) {
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = viewStyle.accessibility.imageLabel
    }
}
