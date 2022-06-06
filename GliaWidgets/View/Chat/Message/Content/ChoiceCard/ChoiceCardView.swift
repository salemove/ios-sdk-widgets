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
                uiApplication: environment.uiApplication
            )
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = viewStyle.frameColor.cgColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = kLayoutMargins
        containerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()

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
            imageView.autoSetDimension(.height, toSize: kImageHeight)
            imageView.setImage(from: imageUrl, animated: true)
            stackView.addArrangedSubview(imageView)
            setupAccessibilityProperties(for: imageView)
        }

        let textView = ChatTextContentView(
            with: style.text,
            contentAlignment: .left,
            environment: .init(
                uiApplication: environment.uiApplication
            ),
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
        var uiApplication: UIKitBased.UIApplication
    }
}

extension ChoiceCardView {
    func setupAccessibilityProperties(for imageView: ImageView) {
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "Choice card"
    }
}
