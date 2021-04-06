import UIKit

final class ChoiceCardView: OperatorChatMessageView {
    var onOptionTapped: ((ChatChoiceCardOption) -> Void)!

    private let viewStyle: ChoiceCardStyle
    private let kLayoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)

    init(with style: ChoiceCardStyle) {
        viewStyle = style
        super.init(with: style)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        contentViews.axis = .vertical
        contentViews.spacing = 12

        contentViews.layer.cornerRadius = 8
        contentViews.layer.borderWidth = 1
        contentViews.layer.borderColor = viewStyle.frameColor.cgColor

        contentViews.isLayoutMarginsRelativeArrangement = true
        contentViews.layoutMargins = kLayoutMargins

        contentViews.setContentHuggingPriority(.required, for: .vertical)
    }

    override func appendContent(_ content: ChatMessageContent, animated: Bool) {
        switch content {
        case .choiceCard(let choiceCard):
            let contentViews = self.contentViews(for: choiceCard)
            appendContentViews(contentViews, animated: animated)
        default:
            break
        }
    }

    private func contentViews(for choiceCard: ChoiceCard) -> [UIView] {
        var views = [UIView]()
        let textView = ChatTextContentView(
            with: style.text,
            contentAlignment: .left,
            withZeroInsets: true
        )
        textView.text = choiceCard.text
        views.append(textView)

        if let imageUrl = choiceCard.imageUrl {
            let imageView = ImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            imageView.setImage(from: imageUrl, animated: true)
            views.append(imageView)
        }

        guard let options = choiceCard.options else { return views }

        let optionViews: [UIView] = options.compactMap { option in
            let optionView = ChatChoiceOptionContentView(with: viewStyle.choiceOption, text: option.text)

            if let selectedValue = choiceCard.selectedOption {
                optionView.isHighlighted = (selectedValue == option.value)
            } else {
                optionView.onTap = { self.onOptionTapped(option) }
            }

            return optionView
        }
        views.append(contentsOf: optionViews)

        return views
    }
}
