import UIKit

final class ChoiceCardView: ChatMessageView {
    private let viewStyle: ChoiceCardStyle
    private let kInsets = UIEdgeInsets(top: 8, left: 40, bottom: 8, right: 60)
    private let kLayoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)

    init(with style: ChoiceCardStyle) {
        viewStyle = style
        super.init(with: style)
        setup()
        layout()
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
        case .text(let text):
            let contentView = ChatTextContentView(with: style.text, withZeroInsets: true)
            contentView.text = text
            appendContentView(contentView, animated: animated)
        case .choiceOptions(let options):
            let contentViews = self.contentViews(for: options)
            appendContentViews(contentViews, animated: animated)
        default:
            break
        }
    }

    private func layout() {
        addSubview(contentViews)
        contentViews.autoPinEdgesToSuperviewEdges(with: kInsets)
    }

    private func contentViews(for options: [ChatChoiceCardOption]) -> [ChatChoiceOptionContentView] {
        return options.compactMap {
            let optionView = ChatChoiceOptionContentView(with: viewStyle.choiceOption)
            optionView.text = $0.text
            return optionView
        }
    }
}
