import UIKit

final class ChoiceCardView: OperatorChatMessageView {
    var onOptionTapped: ((ChatChoiceCardOption) -> Void)!

    private let viewStyle: ChoiceCardStyle
    private let kLayoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    private let kImageHeight: CGFloat = 200.0

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

        if let imageUrl = choiceCard.imageUrl {
            let imageView = ImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            imageView.autoSetDimension(.height, toSize: kImageHeight)
            imageView.setImage(from: imageUrl, animated: true)
            views.append(imageView)
        }

        let textView = ChatTextContentView(
            with: style.text,
            contentAlignment: .left,
            withZeroInsets: true
        )
        textView.text = choiceCard.text
        views.append(textView)

        guard let options = choiceCard.options else { return views }

        let optionViews: [UIView] = options.compactMap { option in
            let optionView = ChoiceCardOptionView(with: viewStyle.choiceOption, text: option.text)

            if let selectedValue = choiceCard.selectedOption {
                optionView.state = option.value == selectedValue
                    ? .selected
                    : .disabled
            } else if choiceCard.isActive {
                optionView.tap = { self.onOptionTapped(option) }
            } else {
                optionView.state = .disabled
            }

            return optionView
        }
        views.append(contentsOf: optionViews)

        return views
    }
}
