import UIKit

final class ChoiceCardView: OperatorChatMessageView {
    var onOptionTapped: ((ChatChoiceCardOption) -> Void)!

    private let viewStyle: Theme.ChoiceCardStyle
    private let kLayoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    private let kImageHeight: CGFloat = 200.0

    private let environment: Environment

    init(with style: Theme.ChoiceCardStyle, environment: Environment) {
        viewStyle = style
        self.environment = environment
        super.init(
            with: .init(
                text: style.text,
                background: style.background,
                imageFile: style.imageFile,
                fileDownload: style.fileDownload,
                operatorImage: style.operatorImage,
                accessibility: .init(isFontScalingEnabled: style.text.accessibility.isFontScalingEnabled)
            ),
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
        containerView.applyBackground(viewStyle.background)

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
            with: .init(
                text: viewStyle.text,
                background: .init(
                    borderColor: .clear,
                    borderWidth: .zero,
                    cornerRadius: .zero
                ),
                accessibility: .init(isFontScalingEnabled: viewStyle.text.accessibility.isFontScalingEnabled)
            ),
            contentAlignment: .left,
            insets: .zero
        )
        textView.text = choiceCard.text
        stackView.addArrangedSubview(textView)
        setupAccessibilityProperties(for: textView)

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

    func setupAccessibilityProperties(for textView: ChatTextContentView) {
        textView.accessibilityLabel = textView.text
        textView.isAccessibilityElement = true
    }
}
